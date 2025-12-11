extends AudioStreamPlayer2D

@export
var interval = 0.0

@export
var max_pitch = 0.0

@export
var min_pitch = 0.0

var timer = 0.0

var should_play = false

func _on_destructable_item_carry_started(follower: CharacterBody2D, num_followers: int, min_followers: int, max_followers: int) -> void:
	should_play = num_followers >= min_followers


func _on_destructable_item_carry_stopped(follower: CharacterBody2D, num_followers: int, min_followers: int, max_followers: int) -> void:
	should_play = num_followers >= min_followers

func _process(delta: float) -> void:
	if should_play && timer <= 0.0:
		pitch_scale = randf_range(min_pitch, max_pitch)
		play()
		timer = interval
	else:
		timer = max(timer - delta, 0)
