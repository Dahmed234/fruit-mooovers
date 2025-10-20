extends Area2D
signal throwMade(throw : Throwable)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("player_throw")):
		throwMade.emit(Throwable.new_throwable(global_position,get_viewport().get_mouse_position()))
		
		
		var throwables :=self.get_overlapping_bodies() #get all pikmin within area
		if(throwables.is_empty()):
			return
		var pikminToThrow = throwables.pop_back()
		
		
		
