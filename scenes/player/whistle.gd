extends Area2D

var isWhistling = false
var whistle_start_played = false

@onready
var whistle_start_player : AudioStreamPlayer2D = $"../../WhistleStart"

@onready
var whistle_loop_player : AudioStreamPlayer2D = $"../../WhistleLoop"

@onready
var original_whistle_volume : float = whistle_loop_player.volume_db
 
@export
var whistle_decay_rate :float = 0.0

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
		
		if !whistle_start_played:
			whistle_start_player.play()
			whistle_start_played = true
		elif whistle_start_played && !whistle_start_player.playing:
			if !whistle_loop_player.playing:
				whistle_loop_player.play()
			
			whistle_loop_player.volume_db -= delta * whistle_decay_rate
	else:
		#$whistleAnim.play("RESET")
		isWhistling = false
		whistle_start_played  = false
		whistle_loop_player.volume_db = original_whistle_volume
		whistle_loop_player.stop()
	
	
	#if(true):
		
		
		
