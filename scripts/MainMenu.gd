extends Node2D

var inGame: PackedScene = preload("res://scenes/In Game.tscn")

func _onStartGame() -> void:
	get_tree().root.add_child(inGame.instantiate())
	queue_free()
