extends Sprite2D


var line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the dotted line texture and set it to repeat 
	line = Line2D.new()
	line.texture = load("res://assets/dotted line.png")
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	line.z_index = 1
	line.width = 8
	line.modulate.a = 0.4
	line.scale = Vector2.ONE / scale
	var poolVectorArray : PackedVector2Array = []
	poolVectorArray.append(Vector2.ZERO)
	# 2nd point will be moved to point at player
	poolVectorArray.append(Vector2.ZERO)
	line.points = poolVectorArray
	add_child(line)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Set position to the mouse, unless mouse is too far from the player
	rotation += delta * PI
	position = get_parent().getThrowPosition()
	line.points[1] = get_parent().global_position - global_position
	line.rotation = -rotation
