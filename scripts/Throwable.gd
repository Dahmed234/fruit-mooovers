extends CharacterBody2D
class_name Throwable



signal objectFinishThrow( pos, state :Follower.State)

var speed :float
var direction :Vector2


@onready
var timer :Timer = $Timer

#@export var scene = 

@export
var WAITTIME: float = 1


var baseScale
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	baseScale = $Sprite2D.scale
	
	timer.wait_time = WAITTIME
	timer.start()


	


func quadratic(x):
	return x * -(x - timer.wait_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = direction * speed
	$Sprite2D.scale = baseScale * (1 +  60*quadratic(timer.wait_time - timer.time_left))
	$Sprite2D.rotation = 5 * PI*(timer.wait_time - timer.time_left)

	if (move_and_collide(velocity * delta)):
		delete(Follower.State.FOLLOW)


func _on_timer_timeout() -> void:
	delete(Follower.State.WANDER)
	queue_free()
	pass # Replace with function body.


func delete(state :Follower.State):
	objectFinishThrow.emit(global_position,state)
	queue_free()
	
