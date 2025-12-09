extends Node2D

@export
var followerScene : PackedScene

@export
var game_scene : PackedScene


func _on_timer_timeout() -> void:
	$Timer.start()
	var newFollower :Node2D = followerScene.instantiate()
	newFollower.global_position = $CanvasLayer/spawnPoint.global_position
	$CanvasLayer.add_child(newFollower)


func _start_game() -> void:
	#var in_game = game_scene.instantiate()
	#get_tree().change_scene_to_packed(in_game)
	get_tree().change_scene_to_packed(game_scene)


func _on_button_2_pressed() -> void:
	get_tree().quit()
