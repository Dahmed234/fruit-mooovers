extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.
	
func _process(delta):
	$Camera2D.position = $Player.position
	
func onCarryFinish(item):
	$Camera2D/Control/Label.changeScore(item.value)
	for i in item.followerValue:
		print("spawned")
		spawnFollower($goal.position,Follower.State.INITIAL)
		
	

func onCarryDrop(item :Carryable):
	pass

func spawnFollower(position, state :Follower.State):
	var newFollower = Follower.newFollower(position,Follower.State.INITIAL)
	newFollower.carryDropped.connect(onCarryDrop)
	newFollower.carryFinished.connect(onCarryFinish)
	add_child(newFollower)
	


func playerMakesThrow(startPosition,mousePosition) -> void:
	var throw = Throwable.new_throwable(startPosition,get_local_mouse_position())
	throw.objectFinishThrow.connect(onThrowFinish)
	add_child(throw)

func onThrowFinish(position :Vector2,state :Follower.State):
	spawnFollower(position, state)
