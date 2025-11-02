extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# move to match mouse position
	global_position = get_global_mouse_position()
	
	
	if(Input.is_action_pressed("player_whistle")):
		var throwables  = self.get_overlapping_bodies().filter(func(item): return item is Follower) #get all pikmin within area
		throwables.map(func(item): item.onWhistle())
	
	
	#if(true):
		
		
		
