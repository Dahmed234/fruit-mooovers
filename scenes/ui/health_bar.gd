extends TextureProgressBar

var fullColour := Color(0,1,0)
var emptyColour := Color(1,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if value == max_value: hide()
	else: show()
	modulate = fullColour * (value / max_value) + emptyColour * (1-(value / max_value))
