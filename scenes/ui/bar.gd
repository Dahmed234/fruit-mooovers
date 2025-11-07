extends Node2D

var fullness := 1.0
var fullColour := Color(0,1,0)
var emptyColour := Color(1,0,0)

@onready var background: Sprite2D = $Background
@onready var value_root: Node2D = $"value root"
@onready var value: Sprite2D = $"value root/Value"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fullness == 1.0: hide()
	else: show()
	value.modulate = fullColour * fullness + emptyColour * (1-fullness)
	value_root.scale.x = clamp(fullness,0.0,1.0)
