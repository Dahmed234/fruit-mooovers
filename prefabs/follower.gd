extends CharacterBody2D

class_name Follower
const scene :PackedScene = preload("res://prefabs/Follower.tscn")

@export
var BASESPEED = 100

var currentspeed = BASESPEED
var SPEEDVARIANCE = 40
var TIMERLENGTH =0.5
var TIMERVARIANCE =0.1



@onready var timer := $Timer
@onready var navAgent := $NavigationAgent2D

var direction := Vector2(0,0)

static func newFollower(pos,startingState: State):
	var follower :Follower = scene.instantiate()
	
	follower.currentState = startingState
	follower.global_position = pos
	return follower
	
	
	
	





var currentState = State.FOLLOW



enum State {
	WANDER,
	FOLLOW,
	IDLE
}


func startWander():
	on_timeout()

func _ready() -> void:
	match currentState:
		State.WANDER:
			startWander()
		State.FOLLOW:
			startFollow()
		State.IDLE:
			startIdle()

	
	

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
			velocity = velocity.slerp(currentspeed * direction, 0.1) 
		State.FOLLOW:
			if navAgent.is_target_reached():
				startIdle()
				pass
			else:
				navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,2,true)
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
	
