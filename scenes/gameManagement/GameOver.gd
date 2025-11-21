extends Control

@export 
var label: Label

var mainMenu: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_message(message: String):
	print(message)


func _on_restart_pressed() -> void:
	mainMenu = load("res://scenes/gameManagement/MainMenu.tscn").instantiate()
	get_tree().root.add_child(mainMenu)
	queue_free()


func _on_quit_pressed() -> void:
	get_tree().quit()
