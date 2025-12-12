extends Control



func _on_resume():
	get_tree().paused = false
	get_parent().hide()

func _on_quit():
	get_tree().quit()

func _on_restart():
	_on_resume()
	
	var to_delete = []
	for node in get_tree().root.get_children():
		if node is CanvasLayer or node is Pauser:
			continue
		to_delete.append(node)
		
	var main_menu = load("res://scenes/gameManagement/New Title Screen.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	
	for node in to_delete:
		node.queue_free()
	# ../../.. is the current root, which we free and replace with the gameOver scene root
	
	
