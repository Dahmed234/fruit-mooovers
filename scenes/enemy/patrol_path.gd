extends Path2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Line2D.points = curve.tessellate_even_length()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
