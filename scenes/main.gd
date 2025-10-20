extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func playerMakesThrow(throw: Throwable) -> void:
	throw.objectFinishThrow.connect(onThrowFinish)
	add_child(throw)

func onThrowFinish(position :Vector2):
	add_child(Follower.newFollower(position,Follower.State.WANDER))
