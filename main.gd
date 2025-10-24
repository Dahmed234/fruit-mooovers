extends Node2D

@export
var thown: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.
	
func _process(delta):
	$Camera2D.position = $Player.position
	
func onCarryFinish(item):
	$Camera2D/Control/Label.changeScore(item.value)
	for i in item.followerValue:
		spawnFollower($goal.position,Follower.State.INITIAL)
	item.queue_free()
	

func onCarryDrop(item :Carryable):
	pass

func spawnFollower(position, state :Follower.State):
	var newFollower = Follower.newFollower(position,Follower.State.INITIAL)
	newFollower.carryDropped.connect(onCarryDrop)
	newFollower.carryFinished.connect(onCarryFinish)
	add_child(newFollower)
	
func new_throwable(currentLocation: Vector2, targetPoint: Vector2) -> Throwable:
	
	var newThrown :Throwable = 	thown.instantiate() 
	newThrown.global_position = currentLocation
	newThrown.direction = currentLocation.direction_to(targetPoint)
	newThrown.speed =  (newThrown.global_position.distance_to(targetPoint)) / newThrown.WAITTIME
	
	return newThrown

func onThrowMade(startPosition,mousePosition) ->void:
	var throw = new_throwable(startPosition,get_local_mouse_position())
	throw.objectFinishThrow.connect(onThrowFinish)
	add_child(throw)

func onThrowFinish(position :Vector2,state :Follower.State):
	print("throw finish")
	spawnFollower(position, state)
