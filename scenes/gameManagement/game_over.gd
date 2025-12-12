extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func set_message(score: int, cows: int):
	var score_label: Label = $VBoxContainer/Score
	var cow_score_label: Label = $"VBoxContainer/Cow Score"

	if (!score_label or !cow_score_label):
		assert(false,"couldn't find score labels in Game Over")

	$VBoxContainer/Score.text = str(score) + "pts."
	
	if cows == 0:
		cow_score_label.text = "All your cows died :("
	else:
		cow_score_label.text = str(cows) + " cows."
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	var gameOver = load("res://scenes/gameManagement/New Title Screen.tscn").instantiate()
	get_tree().root.add_child(gameOver)
	# ../../.. is the current root, which we free and replace with the gameOver scene root
	queue_free()



func _on_quit_pressed() -> void:
	get_tree().quit()
