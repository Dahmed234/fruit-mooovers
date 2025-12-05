extends GPUParticles2D

func _ready() -> void:
	emitting = false

func _on_destructable_item_request_destroy(obj: Node2D) -> void:
	emitting = true
