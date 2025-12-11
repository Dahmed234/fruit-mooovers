extends Area2D
signal throwMade(startPosition, mousePosition,follower)
signal numThrowable(num)
@export
var throwCooldown := 0.25
@export
var throwMinCooldown := 0.05
# Increment each throw to make next throw faster
var throwCombo := 0
var time := 0.0
@onready var player: CharacterBody2D = $"../.."

var throwables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func getClosest(objs):
	var closest = null 
	var closest_distance = 100000000.0
	for obj in objs:
		if obj.global_position.distance_to(global_position) < closest_distance:
			closest = obj
			closest_distance = obj.global_position.distance_to(global_position)
	return closest

func shouldThrow(delta) -> bool:
	if(Input.is_action_just_pressed("player_throw")): return true
	if(Input.is_action_pressed("player_throw")):
		time += delta
		if time > max(throwMinCooldown,throwCooldown - 0.01 * throwCombo):
			time -= max(throwMinCooldown,throwCooldown - 0.01 * throwCombo)
			throwCombo += 1
			return true
		return false
	else:
		throwCombo = 0
		time = 0
		return false
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta: float) -> void:
	throwables  = self.get_overlapping_bodies().filter(func(item): return item is Follower) #get all pikmin within area
		
	throwables= throwables.filter(func(item): return item.canBeThrown())
	numThrowable.emit(throwables.size())
	#on mouse input pressed
	if shouldThrow(delta):
		if(throwables.is_empty()):
			return
		var pikminToThrow :Node2D = getClosest(throwables)
		#pikminToThrow.startThrow()
		# Throw to the mouse, constrained by the player throwable distance
		throwMade.emit(global_position,player.global_position + player.getThrowPosition(),pikminToThrow)
	
