extends GPUParticles2D

func _ready() -> void:
	emitting = false
	
func _on_destructable_item_carry_started(_follower: CharacterBody2D, num_followers: int, min_followers: int, _max_followers: int) -> void:
		emitting = num_followers >= min_followers # Replace with function body.


func _on_destructable_item_carry_stopped(_follower: CharacterBody2D, num_followers: int, min_followers: int, _max_followers: int) -> void:
		emitting = num_followers >= min_followers
