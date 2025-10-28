extends CharacterBody2D

class_name Follower
const scene :PackedScene = preload("res://prefabs/Follower.tscn")

signal carryFinished(item :Carryable)
signal carryDropped(item: ItemData)

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
var TIMERLENGTH =0.5
var TIMERVARIANCE =0.1

# Direction of wandering
var direction := Vector2.ONE

# How detectible are followers to enemy units
const enemy_weight := 0.2
# The distance above rocks the followers sit when destroying
const ITEM_HEIGHT = 20.0

var currentState = State.FOLLOW

@onready var timer := $WanderTimer
@onready var navigation_agent_2d := $NavigationAgent2D

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

# Is the follower in the player's throw radius?
func inThrowRange():
	if !player.throwRadius.throwables: return false
	return self in player.throwRadius.throwables

# Is the follower in a valid state to be thrown, or in the player's throw radius
func canBeThrown():
	
	match currentState:
		State.FOLLOW: return true
		State.IDLE: return true
		State.WANDER: return true
		State.INITIAL: return false
		State.CARRYING: return false
		State.DESTROYING: return false
		State.THROWN: return false

func canBePushed():
	
	match currentState:
		State.FOLLOW: return true
		State.IDLE: return true
		State.WANDER: return true
		State.INITIAL: return true
		State.CARRYING: return false
		State.DESTROYING: return false
		State.THROWN: return false

func onWhistle():
	match currentState:
		State.CARRYING:
			stopCarrying()
		State.DESTROYING:
			stopCarrying()
		State.WANDER:
			endWander()
			startFollow()

# initialises a new follower with given parameters
static func newFollower(pos,startingState: State):
	var follower :Follower = scene.instantiate()
	
	follower.currentState = startingState
	follower.global_position = pos
	# Add follower to the enemy target list
	return follower

func startWander():
	timer.start(TIMERLENGTH + TIMERVARIANCE * randf_range(-1,1))
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
			
			#test to see if items are nearby
			# get all nearby items
			var nearbyLoot   = $viewRadius.get_overlapping_areas()
			var nearbyCarryable
			var nearbyDestroyable
			nearbyCarryable = nearbyLoot.filter(func(item): return item.get_parent() is Carryable)
			nearbyDestroyable = nearbyLoot.filter(func(item): return item.get_parent() is Destroyable)
			
			if(!nearbyCarryable.is_empty()):
				var obtainedItem :Carryable = getClosest(nearbyCarryable).get_parent()#.pop_back().get_parent()
				carryingItem = obtainedItem
				startCarry(obtainedItem)
			elif !nearbyDestroyable.is_empty():
				var obtainedItem :Destroyable = getClosest(nearbyDestroyable).get_parent()
				carryingItem = obtainedItem
				startDestroy(obtainedItem)
			else:
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
	$heldItem/Sprite.texture = null
	label.hide()
	
	#need to wait for all physics components to load in
	# idk why exactly but DO NOT TOUCH THESE OR CARRYING WILL BREAK
	await get_tree().physics_frame
	await get_tree().physics_frame

	initState()

func startCarry(item : Carryable) -> void:
	$heldItem.show()
	label.show()
	
	#setup sprite
	currentState = State.CARRYING
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
	
	if item.followersCarrying.size() > 1:
		hide()
	
	
	#navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,4,true)
	# navigate to goal flag
	navigation_agent_2d.target_position = goal.global_position

func startDestroy(item: Destroyable) -> void:
	# Show the label
	label.show()
	if item.followersCarrying.size() > 1:
		hide()
	
	currentState = State.DESTROYING
	# Ensure the follower snaps above the item so it doesn't move when destroying it
	global_position = item.global_position - Vector2(0.0,ITEM_HEIGHT)
	label.position.y = 10.0 + ITEM_HEIGHT
	item.onPickup(self)
	
	# Disable collision with other followers
	navigation_agent_2d.avoidance_mask = 0
	
	

func startThrow():
	pass

func stopCarrying():
	show()
	$heldItem.hide()
	label.hide()
	velocity = Vector2.ZERO
	carryingItem.onDrop(self)
	carryingItem = null
	
	navigation_agent_2d.avoidance_mask = 1
	
	startWander()


# for navigation: need to wait for first physics frame
func actor_setup():
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	modulate.a = 1
	if canBeThrown(): modulate.a = 1.0 if inThrowRange() else 0.6
	# Push cows out the way of the player if their state allows it
	if canBePushed() && global_position.distance_to(player.global_position) < playerDistance:
		global_position = player.global_position + playerDistance * player.global_position.direction_to(global_position)
	match currentState:
		State.IDLE:
			# triggers if follower is close enough to an area on a specific layer
			# uses specific collision layer to only detect player follower
			if(!$viewRadius.has_overlapping_areas()) :
				startFollow()

		State.WANDER:
			velocity = 0.1* delta * currentspeed * direction#velocity.slerp(0.4* delta * currentspeed * direction, 0.1)
		State.CARRYING:
			label.text = str(int(carryingItem.followersCarrying.size())) + "/" + str(int(carryingItem.weight))
			if navigation_agent_2d.is_target_reached():
				var tmp = carryingItem
				for cow in carryingItem.followersCarrying.keys():
					cow.stopCarrying()
				
				carryFinished.emit(tmp,position)
		
			else:
				navigation_agent_2d.target_position = goal.global_position
				navigate_to_target(delta)
		State.DESTROYING:
			label.text = str(int(carryingItem.followersCarrying.size())) + "/" + str(int(carryingItem.weight))
			global_position = carryingItem.global_position - Vector2(0.0,ITEM_HEIGHT)
			
		State.FOLLOW:
			navigation_agent_2d.target_position = player.global_position
			navigate_to_target(delta)
			#if navigation_agent_2d.is_target_reached():
			#	startIdle()
			#else:

	move_and_slide()

const CHANGEDIRECTIONDISTANCE = 150.0 
#initialises states to idle
func startIdle():
	currentState = State.IDLE
	velocity = Vector2.ZERO

#initialises state to follow
func startFollow():
	currentState = State.FOLLOW
	#use 4 as layer number as it is value for home point
	#navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,2,true)

func endWander():
	direction= Vector2.ONE
	velocity = Vector2.ZERO
	timer.stop()

#used for wander, picks random direction for character to wander to next
func on_timeout() -> void:
	direction = direction.normalized()
	#pick a random direction
	var oldDirection := Vector2(direction)
	
	direction.x = randf_range(-1,1)
	direction.y = randf_range(-1,1)
	direction = direction.normalized()
	
	direction.lerp(oldDirection, randf())
	
	# Set direction to point to the player if the follower is too far away
	if global_position.distance_to(player.global_position) > wanderDistance: 
		direction = global_position.direction_to(player.global_position)
	
	currentspeed = BASESPEED + SPEEDVARIANCE * randf_range(-1,1)
		#start timer again
	timer.start(TIMERLENGTH + TIMERVARIANCE * randf_range(-1,1))

# Basic navigation code based on https://www.youtube.com/watch?v=7ZAF_fn3VOc
func navigate_to_target(delta: float) -> void:
	var local_velocity: float
	if !carryingItem:
		local_velocity = 1.0 
	else:
		if carryingItem.followersCarrying.size() >= carryingItem.weight:
			# Set the speed that the object will be moved,this will be between 10% and 40% of regular speed depending on 
			# How many cows are used
			local_velocity = 0.2 * min(2.0,carryingItem.followersCarrying.size() / carryingItem.weight / 2.0)
		else:
			# Give visual indicator that item is too heavy
			pass
	# Store the current position of the enemy in [current_agent_position]
	var current_agent_position = global_position
	
	# Get the next position along the path to the player
	var next_path_position = navigation_agent_2d.get_next_path_position()
	
	#print(current_agent_position.direction_to(next_path_position),current_agent_position,next_path_position)
	
	# Get the vector moving towards the next path position
	var new_velocity = local_velocity * currentspeed * delta * current_agent_position.direction_to(next_path_position)
	
	
	# Logic for when the enemy reaches the player (i.e. attack them)
	if navigation_agent_2d.is_navigation_finished():
		return
	
	
	# Apply the velocity to the enemy
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	
	# Else calculate a "safe" velocity and apply that
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	
		
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
