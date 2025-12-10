extends GPUParticles2D


func _kill_yourself() -> void:
	queue_free()
