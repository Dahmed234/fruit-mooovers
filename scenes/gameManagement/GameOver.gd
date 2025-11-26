extends Control

@export 
var label: Label

var mainMenu: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_message(score: int, cows: int):
	var score_label: Label = find_child("Score")
	var cow_score_label: Label = find_child("Cow Score")

	if (!score_label or !cow_score_label):
		assert(false,"couldn't find score labels in Game Over")

	score_label.text = str(score) + "pts"
	cow_score_label.text = str(cows) + "cows"


func _on_restart_pressed() -> void:
	print("restart")
	mainMenu = load("res://scenes/gameManagement/MainMenu.tscn").instantiate()
	get_tree().root.add_child(mainMenu)
	queue_free()


func _on_quit_pressed() -> void:
	get_tree().quit()
