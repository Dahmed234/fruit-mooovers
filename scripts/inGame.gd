extends Node2D

@export
var thown: PackedScene

@export 
var splashText: PackedScene

@export 
var goal: Sprite2D
@export
var player: CharacterBody2D

@export 
var zoom_strength := 0.1

@export 
var destructableWalls: TileMapLayer

var isPaused := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnFollower($goal.position,Follower.State.WANDER)
	
func cameraScrolling():
	var zoom = float(Input.is_action_just_released("camera_zoom_in")) - float(Input.is_action_just_released("camera_zoom_out"))
	$Camera2D.zoom *= Vector2.ONE + Vector2.ONE * zoom * zoom_strength
	
	$Camera2D.zoom.x = clamp($Camera2D.zoom.x,0.5,3.0)
	$Camera2D.zoom.y = clamp($Camera2D.zoom.y,0.5,3.0)
	
func _process(delta):
	$Camera2D.position = $Player.position
	
	cameraScrolling()
	
	if Input.is_action_just_pressed("pause"): isPaused = !isPaused

func onCarryFinish(item,pos):
	$UI/Control/Label.score += item.value
	$UI/Control/Label.totalScore += item.value
	$UI/Control/Label.cowScore += item.followerValue
	
	for i in item.followerValue:
		spawnFollower($goal.position,Follower.State.INITIAL)
	# Spawn splash text when the item is droped off
	if item.value > 0:
		var value = splashText.instantiate()
		value.text = str(int(item.value)) + "pts!"
		value.position = pos
		add_child(value)
	if item.followerValue > 0:
		var followers = splashText.instantiate()
		followers.position = pos
		followers.text = str(int(item.followerValue)) + " cows!"
		# Show cows text after a delay so that they don't cover eachother
		followers.delay = 1.5
		add_child(followers)
	item.queue_free()


func onCarryDrop(item :Carryable):
	pass

func add_wall(wall: StaticBody2D):
	$"NavigationRegion2D".add_child(wall)

func spawnFollower(position, state :Follower.State):
	var newFollower = Follower.newFollower(position,Follower.State.WANDER)
	newFollower.carryDropped.connect(onCarryDrop)
	newFollower.carryFinished.connect(onCarryFinish)
	newFollower.goal = goal
	newFollower.player = player
	
	$"NavigationRegion2D".add_child(newFollower)
	
func new_throwable(currentLocation: Vector2, targetPoint: Vector2) -> Throwable:
	
	var newThrown :Throwable = 	thown.instantiate() 
	newThrown.global_position = currentLocation
	newThrown.direction = currentLocation.direction_to(targetPoint)
	newThrown.speed =  (newThrown.global_position.distance_to(targetPoint)) / newThrown.WAITTIME
	
	return newThrown

func onThrowMade(startPosition,mousePosition,follower) ->void:
	var throw = new_throwable(startPosition,mousePosition)
	throw.follower = follower
	follower.thrower= throw
	follower.hide()
	follower.startThrown()
	throw.objectFinishThrow.connect(onThrowFinish)
	add_child(throw)

func onThrowFinish(position :Vector2,state :Follower.State, thrown):
	thrown.follower.show()
	thrown.follower.startInitial()


func _onResume() -> void:
	isPaused = false

func _onQuit() -> void:
	get_tree().quit()
