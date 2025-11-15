extends CharacterBody2D

class_name Follower
const scene :PackedScene = preload("res://scenes/follower/Follower.tscn")

signal carryFinished(item :Carryable)
signal carryDropped(item: ItemData)
signal followerDies(follower)

var carryingItem :StaticBody2D = null


# The bubble around the player that followers are pushed out of
@export
var playerDistance: float

@export
var BASESPEED = 20000

@export
var label: Label

# How far followers can wander from the player
@export
var wanderDistance: float

var goal: Sprite2D
var player: CharacterBody2D 

# variables that effect the followers wander state
var currentspeed = BASESPEED
var SPEEDVARIANCE = 40

# how long character moves in a direction for before wandering
var TIMERLENGTH = 0.5
var TIMERVARIANCE = 0.1

# Direction of wandering
var direction := Vector2.ONE

# How detectible are followers to enemy units
const enemy_weight := 0.2
# The distance above rocks the followers sit when destroying
const ITEM_HEIGHT = 20.0

var currentState = State.FOLLOW

# The object for throwing the cow
var thrower: CharacterBody2D

var chasing: Dictionary[CharacterBody2D,bool] = {}

var max_health
@onready var bar: Node2D = $Bar


# When reaches 0, die
@export var health : float

@onready var timer := $WanderTimer
@onready var navigation_agent_2d := $NavigationAgent2D
@onready var scoreholder: Label = $"../../UI/Control/Label"

# possible states follower can be in
enum State {
	INITIAL,
	CARRYING,
	WANDER,
	FOLLOW,
	IDLE,
	DESTROYING,
	THROWN
}


# Called when this follower becomes the new main carrier of an item
func on_become_main_follower(item) -> void:
	if carryingItem == item and (currentState == State.CARRYING or currentState == State.DESTROYING):
		show()


# Is the follower in the player's throw radius?
func inThrowRange():
	if !player.throwRadius.throwables:
		return false
	return self in player.throwRadius.throwables


# Is the follower in a valid state to be thrown, or in the player's throw radius
func canBeThrown():
	match currentState:
		State.FOLLOW, State.IDLE, State.WANDER:
			return true
		_:
			return false


func canBePushed():
	match currentState:
		State.FOLLOW, State.IDLE, State.WANDER, State.INITIAL:
			return true
		_:
			return false


func onWhistle():
	match currentState:
		State.CARRYING, State.DESTROYING:
			stopCarrying()
		State.WANDER:
			endWander()
			startFollow()


# initialises a new follower with given parameters
static func newFollower(pos, startingState: State):
	var follower :Follower = scene.instantiate()
	follower.currentState = startingState
	follower.global_position = pos
	return follower


func damage(enemy_damage, delta):
	match currentState:
		State.CARRYING, State.DESTROYING:
			# If the main follower for the carried item is alive, send damage to them
			if carryingItem and carryingItem.main_follower:
				carryingItem.main_follower.health -= delta * enemy_damage
			else:
				health -= delta * enemy_damage
		_:
			health -= delta * enemy_damage


func die() -> void:
	# If we are carrying/destroying something, only WE drop it;
	# other followers continue carrying. The item will promote the next main follower.
	if carryingItem:
		var item = carryingItem
		carryingItem = null
		if item.has_method("onDrop"):
			item.onDrop(self)

	if currentState == State.THROWN:
		stopThrow()

	# remove this follower from list of enemies chasing it
	for cone_light in chasing.keys():
		if !cone_light:
			continue
		if !chasing[cone_light]:
			continue
		cone_light.clear_target(self)
	
	scoreholder.cowScore -= 1
	
	queue_free()
	

func startWander():
	show()
	timer.start(TIMERLENGTH + TIMERVARIANCE * randf_range(-1, 1))
	currentState = State.WANDER
	on_timeout()


func startInitial():
	currentState = State.INITIAL
	show()
	initState()


func startThrown():
	hide()
	currentState = State.THROWN


func getClosest(objs):
	var closest = null 
	var closest_distance = 100000000.0
	for obj in objs:
		if obj.global_position.distance_to(global_position) < closest_distance:
			closest = obj
			closest_distance = obj.global_position.distance_to(global_position)
	return closest


# Run the initial logic for the given state
func initState():
	match currentState:
		# decide what to do based on surroundings when landing from a throw
		State.INITIAL:
			var nearbyLoot = $viewRadius.get_overlapping_areas()
			var nearbyCarryable: Array = nearbyLoot.filter(func(item): return item.get_parent() is Carryable)
			var nearbyDestroyable: Array = nearbyLoot.filter(func(item): return item.get_parent() is Destroyable)
			var closest

			# Check all carriables to see if one has capacity
			if !nearbyCarryable.is_empty():
				var found = false
				while !found and nearbyCarryable:
					closest = getClosest(nearbyCarryable)
					if closest.get_parent().hasCapacity(): 
						found = true
					else:
						nearbyCarryable.erase(closest)
				if found:
					var obtainedItem :Carryable = closest.get_parent()
					carryingItem = obtainedItem
					startCarry(obtainedItem)
					return

			# Check all destroyables to see if one has capacity
			if !nearbyDestroyable.is_empty():
				var found_destroy = false
				while !found_destroy and nearbyDestroyable:
					closest = getClosest(nearbyDestroyable)
					if closest.get_parent().hasCapacity(): 
						found_destroy = true
					else:
						nearbyDestroyable.erase(closest)
				if found_destroy:
					var obtainedDestroy :Destroyable = getClosest(nearbyDestroyable).get_parent()
					carryingItem = obtainedDestroy
					startDestroy(obtainedDestroy)
					return

			# If none exist, wander instead
			startWander()

		State.WANDER:
			startWander()
		State.FOLLOW:
			startFollow()
		State.IDLE:
			startIdle()
		_:
			startWander()


func _ready() -> void:
	max_health = health
	$heldItem/Sprite.texture = null
	label.hide()
	
	# need to wait for all physics components to load in
	await get_tree().physics_frame
	await get_tree().physics_frame

	initState()


func startCarry(item :Carryable) -> void:
	$heldItem.show()
	$heldItem.modulate = Color(1, 1, 1)
	label.show()
	
	currentState = State.CARRYING

	# setup sprite
	var currentSprite = $heldItem/Sprite
	var newSprite = item.getSpriteInfo()
	currentSprite.texture = newSprite.texture
	currentSprite.region_rect = newSprite.region_rect
	currentSprite.region_enabled = newSprite.region_enabled
	currentSprite.transform = newSprite.transform
	
	navigation_agent_2d.avoidance_mask = 0
	
	carryingItem = item
	
	# Ensure the follower snaps to the item so it doesn't move when picked up
	global_position = item.global_position
	label.position.y = 10.0
	
	item.onPickup(self)

	# Only the main follower should be visible while carrying
	if item.main_follower != self:
		hide()
	else:
		show()
	
	# navigate to goal flag
	navigation_agent_2d.target_position = goal.global_position


func startDestroy(item: Destroyable) -> void:
	label.hide()

	# Set main follower / follower list via item itself
	item.onPickup(self)

	# Only main follower visible while destroying
	if item.main_follower != self:
		hide()
	else:
		show()
	
	currentState = State.DESTROYING
	# Ensure the follower snaps above the item so it doesn't move when destroying it
	global_position = item.global_position - Vector2(0.0, ITEM_HEIGHT)
	
	# Disable collision with other followers
	navigation_agent_2d.avoidance_mask = 0


func startThrow():
	pass


func stopThrow():
	thrower.stopThrow()


func stopCarrying():
	show()
	$heldItem.hide()
	label.hide()
	velocity = Vector2.ZERO

	if carryingItem:
		var item = carryingItem
		carryingItem = null
		if item.has_method("onDrop"):
			item.onDrop(self)
	
	navigation_agent_2d.avoidance_mask = 1
	
	startWander()


# for navigation: need to wait for first physics frame
func actor_setup():
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	bar.fullness = health / max_health
	if health <= 0:
		die()

	modulate.a = 1.0
	if canBeThrown():
		modulate.a = 1.0 if inThrowRange() else 0.6

	# Push cows out the way of the player if their state allows it
	if canBePushed() and global_position.distance_to(player.global_position) < playerDistance:
		global_position = player.global_position + playerDistance * player.global_position.direction_to(global_position)

	match currentState:
		State.IDLE:
			if !$viewRadius.has_overlapping_areas():
				startFollow()

		State.WANDER:
			navigate_to_target(delta)

		State.CARRYING:
			if carryingItem:
				label.text = str(int(carryingItem.followersCarrying.size())) + "/" + str(int(carryingItem.weight))

				if navigation_agent_2d.is_target_reached():
					var tmp = carryingItem
					# Make all followers drop this item when the destination is reached
					if tmp and tmp.has_method("dropAll"):
						tmp.dropAll()
					carryFinished.emit(tmp, position)
				else:
					navigation_agent_2d.target_position = goal.global_position
					navigate_to_target(delta)

		State.DESTROYING:
			if carryingItem:
				global_position = carryingItem.global_position - Vector2(0.0, ITEM_HEIGHT)

		State.FOLLOW:
			navigation_agent_2d.target_position = player.global_position
			navigate_to_target(delta)

	move_and_slide()


const CHANGEDIRECTIONDISTANCE = 150.0 


# initialises states to idle
func startIdle():
	currentState = State.IDLE
	velocity = Vector2.ZERO


# initialises state to follow
func startFollow():
	currentState = State.FOLLOW


func endWander():
	direction = Vector2.ONE
	velocity = Vector2.ZERO
	timer.stop()


# used for wander, picks random direction for character to wander to next
func on_timeout() -> void:
	direction = direction.normalized()
	# pick a random direction
	var oldDirection := Vector2(direction)
	
	direction.x = randf_range(-1, 1)
	direction.y = randf_range(-1, 1)
	direction = direction.normalized()
	
	direction.lerp(oldDirection, randf())
	
	# Set direction to point to the player if the follower is too far away
	if global_position.distance_to(player.global_position) > wanderDistance: 
		direction = global_position.direction_to(player.global_position)
	
	currentspeed = BASESPEED + SPEEDVARIANCE * randf_range(-1, 1)
	
	navigation_agent_2d.target_position = global_position + direction * currentspeed * TIMERLENGTH / 2
	
	# start timer again
	timer.start(TIMERLENGTH + TIMERVARIANCE * randf_range(-1, 1))


# Basic navigation code
func navigate_to_target(delta: float) -> void:
	var local_velocity: float

	if !carryingItem:
		match currentState:
			State.WANDER:
				local_velocity = 0.5
			_:
				local_velocity = 1.0 
	else:
		if carryingItem.followersCarrying.size() >= carryingItem.weight:
			# Speed while carrying
			local_velocity = 0.4 * min(2.0, carryingItem.followersCarrying.size() / carryingItem.weight / 2.0)
		else:
			# Give visual indicator that item is too heavy (if you want)
			local_velocity = 0.0

	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = local_velocity * currentspeed * delta * current_agent_position.direction_to(next_path_position)
	
	if navigation_agent_2d.is_navigation_finished():
		return
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
