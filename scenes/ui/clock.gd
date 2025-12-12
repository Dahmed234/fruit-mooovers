
extends TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$redbit.value = 60
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$redbit.max_value = max_value
	# -4 so that it loops twice per 24 hours
	$hand.rotation = -4 * PI * (value/max_value)
