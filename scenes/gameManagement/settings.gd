extends Control

func _on_resume():
	get_tree().paused = false
	get_parent().hide()

func _on_quit():
	get_tree().quit()
