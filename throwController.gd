extends Area2D
signal throwMade(startPosition, mousePosition)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#on mouse input pressed
	if(Input.is_action_just_pressed("player_throw")):
		var throwables :=self.get_overlapping_bodies() #get all pikmin within area
		if(throwables.is_empty()):
			return
		var pikminToThrow :Node2D = throwables.pop_back()
		pikminToThrow.queue_free()
		throwMade.emit(global_position,get_viewport().get_mouse_position())
		
		
		
		
		
