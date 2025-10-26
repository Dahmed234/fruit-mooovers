extends Sprite2D

@export 
var alpha: float

enum State {
	PATROLLING  = 0,
	ALERT 		= 1,
	CHASING		= 2,
	IDLE 		= 3
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match (get_parent().get_parent().current_state):
		State.ALERT: 
			modulate = Color(1,1,0,alpha)
		State.CHASING: 
			modulate = Color(1,0,0,alpha)
		_:
			modulate = Color(0,1,0,alpha)
