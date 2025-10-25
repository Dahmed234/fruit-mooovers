extends Node2D

var inGame: PackedScene = preload("res://scenes/In Game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inGame = preload("res://scenes/In Game.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	get_tree().root.add_child(inGame.instantiate())
	queue_free()
