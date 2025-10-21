extends CharacterBody2D

class_name Follower
const scene :PackedScene = preload("res://prefabs/Follower.tscn")

@export


var BASESPEED = 100

# variables that effect the followers wander state
var currentspeed = BASESPEED
var SPEEDVARIANCE = 40

# how long character moves in a direction for before wandering
var TIMERLENGTH =0.5
var TIMERVARIANCE =0.1

var direction := Vector2(0,0)


var currentState = State.FOLLOW

@onready var timer := $WanderTimer
@onready var navAgent := $NavigationAgent2D

# possible states follower can be in
enum State {
	INITIAL,
	CARRYING,
	WANDER,
	FOLLOW,
	IDLE
}

# initialises a new follower with given parameters
static func newFollower(pos,startingState: State):
	var follower :Follower = scene.instantiate()
	
	follower.currentState = startingState
	follower.global_position = pos
	return follower




func startWander():
	on_timeout()



func _ready() -> void:
	$heldItem/Sprite.texture = null
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	
	
	
	match currentState:
		
		
		# decide what to do based on surroundings
		State.INITIAL:

			
			#test to see if items are nearby
			# get all nearby items
			
			var nearbyLoot   = $viewRadius.get_overlapping_areas()
			nearbyLoot = nearbyLoot.filter(func(item): return item.get_parent() is Carryable)
			
			if(!nearbyLoot.is_empty()):
				var obtainedItem :Carryable = nearbyLoot.pop_back().get_parent()
				startCarry(obtainedItem)	
		State.WANDER:
			startWander()
		State.FOLLOW:
			startFollow()
		State.IDLE:
			startIdle()

	
			
func startCarry(item : Carryable):
	
	#setup sprite
	currentState = State.CARRYING
	var currentSprite = $heldItem/Sprite
	var newSprite = item.getSpriteInfo()
	currentSprite.texture = newSprite.texture
	currentSprite.region_rect = newSprite.region_rect
	currentSprite.region_enabled = newSprite.region_enabled
	currentSprite.transform = newSprite.transform
	
	item.onPickup()
	
	navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,4,true)
	
	
	
	
	
	pass

# for navigation: need to wait for first physics frame
func actor_setup():
	await get_tree().physics_frame


func _physics_process(delta: float) -> void:
	
	
	
	match currentState:
		
		State.IDLE:
			
			# triggers if follower is close enough to an area on a specific layer
			# uses specific collision layer to only detect player follower
			if(!$viewRadius.has_overlapping_areas()) :
				startFollow()
		
		State.WANDER:
			velocity = velocity.slerp(0.4* currentspeed * direction, 0.1) 
		
		State.CARRYING:
			if navAgent.is_target_reached():
				$heldItem/Sprite.texture = null
				velocity = Vector2.ZERO
				startWander()
			else:
				var next_path_position :Vector2 = navAgent.get_next_path_position()
				velocity = global_position.direction_to(next_path_position) * BASESPEED
		State.FOLLOW:
			if navAgent.is_target_reached():
				startIdle()
			
				pass
			else:
				navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,2,false)
				var next_path_position :Vector2 = navAgent.get_next_path_position()
				velocity = global_position.direction_to(next_path_position) * BASESPEED
	# pick direction to move in
	# move in it for specified time 
	# pick new direction
	move_and_slide()

#initialises states to idle
func startIdle():
	currentState = State.IDLE
	velocity = Vector2.ZERO

#initialises state to follow
func startFollow():
	currentState = State.FOLLOW
	
	#use 4 as layer number as it is value for home point
	navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,2,true)
	
	


#used for wander, picks random direction for character to wander to next
func on_timeout() -> void:
	#pick a random direction
	var oldDirection := Vector2(direction)
	direction.x = randf_range(-1,1)
	direction.y = randf_range(-1,1)
	direction = direction.normalized()
	
	direction.lerp(oldDirection, randf())	
	currentspeed = BASESPEED + SPEEDVARIANCE * randf_range(-1,1)	
		#start timer again
	timer.start(TIMERLENGTH + TIMERVARIANCE * randf_range(-1,1))
	
