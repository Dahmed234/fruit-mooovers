extends GPUParticles2D

func _ready() -> void:
	emitting = false
	
func _on_destructable_item_carry_started(_follower: CharacterBody2D, num_followers: int, min_followers: int, _max_followers: int) -> void:
	if (num_followers >= min_followers):
		emitting = true # Replace with function body.


func _on_destructable_item_carry_stopped(_follower: CharacterBody2D, num_followers: int, min_followers: int, _max_followers: int) -> void:
	if (num_followers < min_followers):
		emitting = false # Replace with function body.
