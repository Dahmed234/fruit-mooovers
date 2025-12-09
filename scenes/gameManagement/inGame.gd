extends Node2D

const INITIAL_FOLLOWERS: int = 25

@export
var thown: PackedScene

@export 
var splashText: PackedScene

@export 
var goal: Sprite2D
@export
var player: CharacterBody2D

@onready var label: Label = $UI/Control/Label

@export 
var zoom_strength := 0.1

@export 
var destructableWalls: TileMapLayer

var isPaused := false
# Called when the node enters the scene tree for the first time.

@onready
var mooSoundPlayer : AudioStreamPlayer = $MooSoundPlayer

var timeSinceLastMoo : float = 0

@export
var minTimeBetweenMoos : float = 0

@export
var maxTimeBetweenMoos : float = 0

@onready
var timeBetweenMoos : float = randf_range(minTimeBetweenMoos, maxTimeBetweenMoos)

@export
var throwMooMinPitch : float = 0;

@export
var throwMooMaxPitch : float = 0;

@export
var idleMooMinPitch : float = 0;

@export
var idleMooMaxPitch : float = 0;

func _ready() -> void:
	for i in range(INITIAL_FOLLOWERS):
		spawnFollower($goal.global_position + Vector2(randf(),randf()),Follower.State.WANDER)
	
func cameraScrolling():
	var zoom = float(Input.is_action_just_released("camera_zoom_in")) - float(Input.is_action_just_released("camera_zoom_out"))
	$Camera2D.zoom *= Vector2.ONE + Vector2.ONE * zoom * zoom_strength
	
	$Camera2D.zoom.x = clamp($Camera2D.zoom.x,0.5,3.0)
	$Camera2D.zoom.y = clamp($Camera2D.zoom.y,0.5,3.0)
	
func _process(delta):
	$Camera2D.position = $Player.position
	
	cameraScrolling()
	
	if Input.is_action_just_pressed("pause"): isPaused = !isPaused
	
	if (!mooSoundPlayer.playing):
		if (timeSinceLastMoo >= timeBetweenMoos):
			mooSoundPlayer.pitch_scale = randf_range(idleMooMinPitch, idleMooMaxPitch);
			mooSoundPlayer.play();
			timeSinceLastMoo = 0;
			timeBetweenMoos = randf_range(minTimeBetweenMoos, maxTimeBetweenMoos);
		else:
			timeSinceLastMoo += delta;

func onCarryFinish(item,pos):
	label.score += item.value
	label.totalScore += item.value
	
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


func add_wall(wall: StaticBody2D):
	$"NavigationRegion2D".add_child(wall)

func spawnFollower(n_position, state :Follower.State):
	label.cowScore += 1
	var newFollower = Follower.newFollower(n_position,state)
	newFollower.carryFinished.connect(onCarryFinish)
	newFollower.goal = goal
	newFollower.player = player
	# randomise colour a lil bit
	var greyness = 1 - randf() * 0.2
	newFollower.modulate = Color(greyness,greyness,greyness)
	
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
	
	#play moo sfx
	timeSinceLastMoo = 0.0
	mooSoundPlayer.pitch_scale = randf_range(throwMooMinPitch, throwMooMaxPitch)
	mooSoundPlayer.play()

func onThrowFinish(_n_position :Vector2,_state :Follower.State, thrown):
	thrown.follower.show()
	thrown.follower.startInitial()


func _onResume() -> void:
	isPaused = false

func _onQuit() -> void:
	get_tree().quit()
