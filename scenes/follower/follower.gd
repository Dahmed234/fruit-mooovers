extends CharacterBody2D

class_name Follower
const follower_scene :PackedScene = preload("res://scenes/follower/Follower.tscn")

signal carryFinished(item :Carryable)
#signal carryDropped(item: ItemData)
#signal followerDies(follower)

var carryingItem :StaticBody2D = null
var is_moving = false
@export var playerDistance: float
@export var BASESPEED = 20000
@export var label: Label
@export var wanderDistance: float

var can_regen = false

var goal: Sprite2D
var player: CharacterBody2D 

var currentspeed = BASESPEED
var SPEEDVARIANCE = 40
var TIMERLENGTH = 0.5
var TIMERVARIANCE = 0.1

var direction := Vector2.ONE

## How quickly followers are detected, big number = start attacking faster. 
const detection_weight := 0.2
const ITEM_HEIGHT = 20.0

var currentState = State.FOLLOW

var thrower: CharacterBody2D
var chasing: Dictionary[CharacterBody2D,bool] = {}

var max_health
@export var health : float
@onready var health_bar: TextureProgressBar = $Sprite2D/Health

@onready var timer := $WanderTimer
@onready var navigation_agent_2d :NavigationAgent2D = $NavigationAgent2D

signal cow_died
# --- NEW: behaviour objects ---
var movement        # FollowerMovement
var wander_behavior # FollowerWander
var carry_behavior  # FollowerCarry
var destroy_behavior # FollowerDestroy

# V important, used to make _process wait for everything to be fully loaded
var is_ready = false
enum State {
	INITIAL,
	CARRYING,
	WANDER,
	FOLLOW,
	IDLE,
	DESTROYING,
	THROWN
}

# --- API called from outside stays the same ---

func on_become_main_follower(item) -> void:
	if carryingItem == item and (currentState == State.CARRYING or currentState == State.DESTROYING):
		show()


func inThrowRange():
	if !player.throwRadius.throwables:
		return false
	return self in player.throwRadius.throwables


func canBeThrown():
	match currentState:
		State.FOLLOW, State.IDLE:
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


static func newFollower(pos, startingState: State):
	var follower :Follower = follower_scene.instantiate()
	follower.currentState = startingState
	follower.global_position = pos
	return follower


func damage(enemy_damage):
	can_regen = false
	$"Regen timer".start()
	match currentState:
		State.CARRYING, State.DESTROYING:
			if carryingItem and carryingItem.main_follower:
				carryingItem.main_follower.health -= enemy_damage
			else:
				health -= enemy_damage
		_:
			health -= enemy_damage

var dead = false
func die() -> void:
	if dead:
		return
	dead = true
	if currentState == State.CARRYING or currentState == State.DESTROYING:
		carry_behavior.stop()
	
		

	if currentState == State.THROWN:
		stopThrow()

	for cone_light in chasing.keys():
		if !cone_light:
			continue
		if !chasing[cone_light]:
			continue
		cone_light.clear_target(self)
	
	collision_layer = 0
	
	cow_died.emit()
	$viewRadius.monitorable = false
	$viewRadius.monitoring = false
	$"Enemy detection box".monitorable = false
	$"Enemy detection box".monitoring = false
	$AnimationTree.active = false
	$AnimationPlayer.play("Death")
	$DeathSound.play()
	print("death should be playing?")
	await $AnimationPlayer.animation_finished
	#scoreholder.cowScore -= 1
	queue_free()
	

# --- STATE ENTRY HELPERS (now mostly delegate to behaviours) ---

func startWander():
	wander_behavior.start()


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
		var d = obj.global_position.distance_to(global_position)
		if d < closest_distance:
			closest = obj
			closest_distance = d
	return closest


func initState():
	match currentState:
		State.INITIAL:
			var nearbyLoot = $viewRadius.get_overlapping_areas()
			var nearbyCarryable: Array = nearbyLoot.filter(
				func(item): return item.get_parent() is Carryable
			)
			var nearbyDestroyable: Array = nearbyLoot.filter(
				func(item): return item.get_parent() is Destroyable
			)
			var closest

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
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	max_health = health
	health_bar.max_value = max_health
	$Sprite2D/heldItem/Sprite.texture = null
	label.hide()
	
	# create behaviours
	movement = FollowerMovement.new(self)
	wander_behavior = FollowerWander.new(self)
	carry_behavior = FollowerCarry.new(self)
	destroy_behavior = FollowerDestroy.new(self)

	# need to wait for all physics components to load in
	

	initState()

	is_ready = true

# --- delegated behaviours ---

func startCarry(item :Carryable) -> void:
	carry_behavior.start(item)


func startDestroy(item: Destroyable) -> void:
	destroy_behavior.start(item)


func startThrow():
	# TODO: implement throw behaviour
	pass


func stopThrow():
	thrower.stopThrow()


func stopCarrying():
	carry_behavior.stop()
	# original behaviour: go back to wandering
	startWander()


func actor_setup():
	await get_tree().physics_frame


func _process(delta: float) -> void:
	$Footsteps.play_footstep = is_moving and !dead;
	
	if !is_ready: 
		print("follower wait for ready")
		return
	
	if can_regen:
		health = max(max_health, health + max_health / 10 * delta)
	
	health_bar.value = health
	
	$Sprite2D.flip_h = velocity.x < 0
	
	if health <= 0:
		die()

	modulate.a = 1.0
	if canBeThrown():
		modulate.a = 1.0 if inThrowRange() else 0.6

	if canBePushed() and global_position.distance_to(player.global_position) < playerDistance:
		global_position = player.global_position \
			+ playerDistance * player.global_position.direction_to(global_position)

	match currentState:
		State.IDLE:
			if !$viewRadius.has_overlapping_areas():
				startFollow()

		State.WANDER:
			movement.navigate_to_target(delta)

		State.CARRYING:
			if carryingItem:
				carry_behavior.physics_update(delta)

		State.DESTROYING:
			destroy_behavior.physics_update(delta)

		State.FOLLOW:
			
			navigation_agent_2d.target_position = player.global_position
			movement.navigate_to_target(delta)

	
	is_moving = velocity.length() > 40.0

	move_and_slide()


const CHANGEDIRECTIONDISTANCE = 150.0 

func startIdle():
	currentState = State.IDLE
	velocity = Vector2.ZERO


func startFollow():
	currentState = State.FOLLOW


func endWander():
	wander_behavior.end()


func on_timeout() -> void:
	wander_behavior.on_timeout()


func navigate_to_target(delta: float) -> void:
	movement.navigate_to_target(delta)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _regen_timeout() -> void:
	can_regen = true
