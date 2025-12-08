extends Path2D

func _ready() -> void:
	# Give the path data to the visual path the enemy will follow
	$Line2D.points = curve.tessellate_even_length()
