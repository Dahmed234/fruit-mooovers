extends CharacterBody2D

@export
var BASESPEED = 100

var currentspeed = BASESPEED
var SPEEDVARIANCE = 40
var TIMERLENGTH =0.5
var TIMERVARIANCE =0.1

@export var playerArea :Area2D

@onready var timer := $Timer
@onready var navAgent := $NavigationAgent2D

@export var navRegion :NavigationRegion2D

@export var leader: Node2D

var direction := Vector2(0,0)





var currentState = State.FOLLOW



enum State {
	WANDER,
	FOLLOW,
	IDLE
}


func _ready() -> void:
	
	startFollow()
	timer.start()
	
	

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

func startIdle():
	currentState = State.IDLE
	velocity = Vector2.ZERO

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
	
