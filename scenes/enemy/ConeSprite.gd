extends Sprite2D

@export 
var alpha: float


enum State {
	PATROLLING  = 0,
	ALERT 		= 1,
	CHASING		= 2,
	IDLE 		= 3
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	match (get_parent().get_parent().current_state):
		State.ALERT: 
			modulate = Color(1,1,0,alpha)
		State.CHASING: 
			modulate = Color(1,0,0,alpha)
		_:
			modulate = Color(0,1,0,alpha)
