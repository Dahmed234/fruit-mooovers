extends AudioStreamPlayer2D

@export
var footstep_interval = 0.0

@export
var footstep_max_pitch = 0.0

@export
var footstep_min_pitch = 0.0

var footstep_timer = 0.0

@export
var play_footstep : bool = false;

func _process(delta: float) -> void:
	if play_footstep && footstep_timer <= 0.0:
		pitch_scale = randf_range(footstep_min_pitch, footstep_max_pitch)
		play();
		footstep_timer = footstep_interval
	else:
		footstep_timer = max(footstep_timer - delta, 0)
