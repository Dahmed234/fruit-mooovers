extends CharacterBody2D

@export var flicker: float 
@export var pulse_rate: float
@export var pulse_amount: float
@export var turn_speed: float
@export var size: float

var local_size: float
var target_angle := 0.0
var in_area : Dictionary[CharacterBody2D,bool] = {}
var angle_delta: float
var clockwise
var anticlockwise
enum State {
	PATROLLING  = 0,
	ALERT 		= 1,
	CHASING		= 2,
	IDLE 		= 3
}

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
			# Set the light to have radius of [light_level] pixels
	
			# Where we want to be pointing
			angle_delta = target_angle - rotation - PI/2
			if angle_delta > -turn_speed * delta:
				rotation += turn_speed * delta
			elif angle_delta < turn_speed * delta:
				rotation -= turn_speed * delta
				
		State.CHASING:
			look_at(get_parent().get_closest_unit().position)
			rotation += PI/2
		_:
			pass
	scale = (local_size * size + (randf() * flicker) + (pulse_amount * sin(Time.get_ticks_msec() / pulse_rate))) * Vector2(get_parent().light_level / 256,get_parent().light_level / 256)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_light(delta)

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	if other_shape_node.get_parent().get_parent() in get_parent().target:
		in_area[other_shape_node.get_parent().get_parent()] = true

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	#return out if any inputs are invalid
	if !area_shape_index:	return
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	
	if !other_shape_owner:	return
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	
	if !other_shape_node or !other_shape_node.get_parent() or !other_shape_owner.get_parent().get_parent():	return
	
	if other_shape_node.get_parent().get_parent() in get_parent().target:
		in_area[get_parent().target] = false
