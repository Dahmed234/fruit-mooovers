extends Area2D

var isWhistling = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	rotation += delta 
	
	# move to match mouse position
	global_position = get_global_mouse_position()
	
	
	if(Input.is_action_pressed("player_whistle")):
		isWhistling = true
		#$whistleAnim.play("grow_whistle")
		var throwables  = self.get_overlapping_bodies().filter(func(item): return item is Follower) #get all pikmin within area
		throwables.map(func(item): item.onWhistle())
	else:
		#$whistleAnim.play("RESET")
		isWhistling = false
	
	
	#if(true):
		
		
		
