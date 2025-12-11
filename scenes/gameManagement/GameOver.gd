extends Control

@export 
var label: Label

var mainMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_restart_pressed() -> void:
	mainMenu = load("res://scenes/gameManagement/New Title Screen.tscn").instantiate()
	get_tree().root.add_child(mainMenu)
	queue_free()


func _on_quit_pressed() -> void:
	get_tree().quit()
