extends PointLight2D

@export var flicker: float 
@export var pulse_rate: float
@export var pulse_amount: float

func update_light() -> void:
	# Set the light to have radius of [light_level] pixels
	scale = (1.0 + (randf() * flicker) + (pulse_amount * sin(Time.get_ticks_msec() / pulse_rate))) * Vector2(get_parent().light_level / 256,get_parent().light_level / 256)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_light()
