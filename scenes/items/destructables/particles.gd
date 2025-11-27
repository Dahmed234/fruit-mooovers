extends GPUParticles2D

func _ready() -> void:
	emitting = false
	
func _on_destructable_item_carry_started(follower: CharacterBody2D) -> void:
	emitting = true # Replace with function body.


func _on_destructable_item_carry_stopped(follower: CharacterBody2D) -> void:
	emitting = false # Replace with function body.
