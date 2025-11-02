extends CharacterBody2D

@export var flicker: float 
@export var pulse_rate: float
@export var pulse_amount: float
@export var turn_speed: float
@export var size: float
@export var chaseTime:float

var local_size: float
var target_angle := 0.0
# Used to perfrom updates each frame an agent is in the collision, rather than just onenter / onexit
var in_area : Dictionary[CharacterBody2D,bool] = {}
# A list of all agents that recently were in collision
var targets : Dictionary[CharacterBody2D,float] = {}
var angle_delta: float
var clockwise
var anticlockwise
enum State {
	PATROLLING  = 0,
	ALERT 		= 1,
	CHASING		= 2,
	IDLE 		= 3
}

func clear_target(target):
	targets.erase(target)
	in_area.erase(target)

func mod(a: float, b: float) -> float:
	var div = int(a/b)
	var frac = a/b - div
	return frac * b
func update_light(delta: float) -> void:
	match (get_parent().current_state):
		State.IDLE:
			local_size = 1.1
		State.ALERT,State.CHASING:
			local_size = 1.8
		_:
			local_size = 1.0
	match (get_parent().current_state):
		State.PATROLLING,State.ALERT,State.IDLE:
			# Where we want to be pointing, get the angle from the current vector to the target vector
			angle_delta = Vector2.from_angle(target_angle).angle_to(Vector2.from_angle(global_rotation - PI/2))

			# Move towards this angle at a fixed speed
			if angle_delta > 2 * -turn_speed * delta:
				rotation += turn_speed * delta
			elif angle_delta < 2 * turn_speed * delta:
				rotation -= turn_speed * delta
			else:
				rotation += angle_delta
		State.CHASING:
			if get_parent().get_best_target():
				look_at(get_parent().get_best_target().position)
				rotation += PI/2
		_:
			pass
	scale = (local_size * size + (randf() * flicker) + (pulse_amount * sin(Time.get_ticks_msec() / pulse_rate))) * Vector2(get_parent().light_level / 256,get_parent().light_level / 256)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_light(delta)
	
	# Mark all targets in the area as elligable targets
	for target in in_area.keys():
		targets[target] = chaseTime
	
func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	
	# Set the target as in the area and being chased
	if other_shape_node.get_parent().get_parent():
		in_area[other_shape_node.get_parent().get_parent()] = true
		other_shape_node.get_parent().get_parent().chasing[self] = true
		
	

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	# Handles case of follower being thrown while in area
	if !area:
		return
		
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	
	#if !other_shape_owner:	return
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	
	#if !other_shape_node or !other_shape_node.get_parent() or !other_shape_owner.get_parent().get_parent():	return
	
	#if other_shape_node.get_parent().get_parent() in get_parent().target:
	in_area.erase(other_shape_node.get_parent().get_parent())
