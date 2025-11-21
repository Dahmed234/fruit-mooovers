extends Control

const in_game = preload("uid://eb0mqkobwsnn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _start_game() -> void:
	get_tree().change_scene_to_packed(in_game)
