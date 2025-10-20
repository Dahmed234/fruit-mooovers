extends CharacterBody2D
class_name Throwable



signal objectFinishThrow( pos)

var speed :float
var direction :Vector2


@onready
var timer :Timer = $Timer

# might cause a glitch? idk
const scene : PackedScene = preload("res://prefabs/Thrown_object.tscn")

@export
var WAITTIME: float = 1


var baseScale
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	baseScale = $Sprite2D.scale
	
	timer.wait_time = WAITTIME
	timer.start()
	print("object gyatt thrown")
	pass # Replace with function body.


static func new_throwable(currentLocation: Vector2, targetPoint: Vector2):
	
	var newThrown :Throwable = 	scene.instantiate() 
	newThrown.global_position = currentLocation
	newThrown.direction = currentLocation.direction_to(targetPoint)
	newThrown.speed =  (newThrown.global_position.distance_to(targetPoint)) / newThrown.WAITTIME
	
	
	return newThrown
	


func quadratic(x):
	return x * -(x - timer.wait_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = direction * speed
	$Sprite2D.scale = baseScale * (1 +  60*quadratic(timer.wait_time - timer.time_left))
	move_and_slide()


func _on_timer_timeout() -> void:
	objectFinishThrow.emit(global_position)
	queue_free()
	pass # Replace with function body.
