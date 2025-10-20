extends CharacterBody2D
class_name Throwable

@export
var speed :float
var direction :Vector2


@onready
var timer :Timer = $Timer

# might cause a glitch? idk
const scene : PackedScene = preload("res://prefabs/Thrown_object.tscn")
const WAITTIME: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = WAITTIME
	timer.start()
	print("object gyatt thrown")
	pass # Replace with function body.


static func new_throwable(currentLocation: Vector2, targetPoint: Vector2):
	
	var newThrown :Throwable = 	scene.instantiate() 
	newThrown.position = currentLocation
	newThrown.direction = targetPoint.normalized()
	newThrown.speed =  (newThrown.position.distance_to(targetPoint)) / newThrown.WAITTIME
	
	
	return newThrown
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
