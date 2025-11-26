extends Control

var in_game

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _start_game() -> void:
	in_game = load("res://scenes/gameManagement/InGame.tscn").instantiate()
	#get_tree().change_scene_to_packed(in_game)
	get_tree().root.add_child(in_game)
	queue_free()
