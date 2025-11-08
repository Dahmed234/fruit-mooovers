extends Node2D

@export var main_menu: PackedScene
@export var in_game: PackedScene
@export var game_over: PackedScene

enum State {
	MAIN_MENU = 0,
	IN_GAME = 1,
	PAUSED = 2,
	GAME_OVER = 3,
}

var current_state: State = State.MAIN_MENU
var current_scene

func change_scene(scene: PackedScene):
	if current_scene: current_scene.queue_free()
	var new_scene = scene.instantiate()
	current_scene = new_scene
	add_child(new_scene)
	new_scene.connect("button_pressed",_on_button_pressed)

func _ready() -> void:
	change_scene(main_menu)
	
func _on_button_pressed(button_name):
	match button_name:
		"Start Game", "Resume Game":
			change_scene(in_game)
		"Restart":
			change_scene(main_menu)
		"Quit":
			get_tree().quit()
		
