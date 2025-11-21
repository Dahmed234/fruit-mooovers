extends Node2D

@export var main_menu: PackedScene
@export var in_game: PackedScene
@export var game_over: PackedScene
@export var settings: PackedScene

enum State {
	MAIN_MENU = 0,
	IN_GAME = 1,
	PAUSED = 2,
	GAME_OVER = 3,
}

var current_state: State = State.MAIN_MENU
var current_scene
var tmp_state
var tmp_scene

func change_scene(scene: PackedScene):
	if tmp_scene: tmp_scene.queue_free()
	if current_scene: current_scene.queue_free()
	var new_scene = scene.instantiate()
	current_scene = new_scene
	add_child(new_scene)
	new_scene.connect("button_pressed",_on_button_pressed)

func scene_on_top(scene: PackedScene = null):
	if tmp_scene: tmp_scene.queue_free()
	if !scene: return
	var new_scene = scene.instantiate()
	tmp_scene = new_scene
	add_child(new_scene)
	new_scene.connect("button_pressed",_on_button_pressed)

func _ready() -> void:
	change_scene(main_menu)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"): _on_pause()

func _on_button_pressed(button_name):
	match button_name:
		"Start Game":
			current_state = State.IN_GAME
			change_scene(in_game)
		"Restart":
			current_state = State.MAIN_MENU
			change_scene(main_menu)
		"Quit":
			get_tree().quit()
		"Resume Game":
			_on_pause()

func _on_pause():
	if current_state == State.PAUSED:
		current_state = tmp_state
		scene_on_top()
	else:
		tmp_state = current_state
		current_state = State.PAUSED
		scene_on_top(settings)
