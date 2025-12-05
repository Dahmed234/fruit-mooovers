extends Interactable

class_name Carryable




func _ready() -> void:
	super._ready()

@onready
var bottom :Node2D = $bottom

@onready
var bounds :Rect2 = $Area2D/CollisionShape2D2.shape.get_rect()

@export 
var fruitName : String

func _process(delta: float) -> void:
	# If at least one follower is carrying, follow the main follower
	if main_follower:
		global_position = main_follower.global_position


func _on_first_follower_added() -> void:
	# Disable collisions and hide the item when picked up
	hide()
	var shape := $CollisionShape2D
	if shape:
		shape.disabled = true



func _on_no_followers_left() -> void:
	# Re-enable collisions and show the item when dropped
	var shape := $CollisionShape2D
	if shape:
		shape.disabled = false
	show()
