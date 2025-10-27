extends Area2D
signal throwMade(startPosition, mousePosition,follower)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	throwables  = self.get_overlapping_bodies().filter(func(item): return item is Follower) #get all pikmin within area
		
	throwables= throwables.filter(func(item): return item.canBeThrown())
	#on mouse input pressed
	if(Input.is_action_just_pressed("player_throw")):
		
		
		if(throwables.is_empty()):
			return
		var pikminToThrow :Node2D = getClosest(throwables)
		#pikminToThrow.startThrow()
		# Throw to the mouse, constrained by the player throwable distance
		throwMade.emit(global_position,player.global_position + player.getThrowPosition(),pikminToThrow)
	
