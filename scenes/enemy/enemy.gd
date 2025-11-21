extends CharacterBody2D


@export var speed: float
@export var light_level: float 
@export var cone_light: CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var destructable_item: Destroyable = $"Destructable Item"

var line
var laser_colour = Color(1,0,0)

const min_alert = 50.0
const max_alert = 200.0

#var target: Dictionary[CharacterBody2D,bool]
# Possible enemy states.
enum State {
	PATROLLING  = 0,
	ALERT 		= 1,
	CHASING		= 2,
	IDLE 		= 3
}

# Current enemy state
var current_state	:= State.PATROLLING
# Current idle wandering target
var idle_target  	:= Vector2(0,0)
# Current patrolling node
var patrol_target: int
# Distance that the enemy will try to wander to
var idle_distance	:= 50.0
# Time (s) between changing idle position
var idle_delay		:= 5.0
# Time (s) since last idle movement
var idle_time		:= 0.0
# The speed of movements, is slower when enemy is exploring vs when they're chasing
var local_speed     := 0.5

# shoot time increases until it reaches cooldown, if it is less than shoot length then display the shot
@export
var shoot_length := 0.1
@export
var shoot_cooldown := 0.3
var shoot_time := 0.0
@export
# Damage dealt per second of being hit by laser
var damage := 50.0

@export 
var range := 50.0

# How long the enemy has seen the player
var alert_level := 0.0

var at_patrol_target = true



func _ready() -> void:
	# Make a line object used to show laser shooting
	line = Line2D.new()
	#line.texture = load("res://assets/dotted line.png")
	#line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	#line.texture_mode = Line2D.LINE_TEXTURE_TILE
	#line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	line.z_index = 1
	line.width = 8
	line.modulate = laser_colour
	line.scale = Vector2.ONE / scale
	var poolVectorArray : PackedVector2Array = []
	poolVectorArray.append(Vector2.ZERO)
	# 2nd point will be moved to point at player
	poolVectorArray.append(Vector2.ZERO)
	line.points = poolVectorArray
	add_child(line)
	line.hide()

func die() -> void:
	for cow in cone_light.targets.keys():
		cow.chasing.erase(cone_light)
	#get_parent().enemy_alive_count -= 1
	queue_free()

func shoot(target,delta) -> void:
	shoot_time += delta
	if shoot_time < shoot_length:
		line.show()
		line.points[1] = target.global_position - global_position
		
		# Deal damage whenever laser is on the target
		target.damage(damage,delta)
	while shoot_time > shoot_cooldown: shoot_time -= shoot_cooldown

func get_best_target() -> CharacterBody2D:
	var best = null 
	var bestScore = 1000000.0
	var tmpScore
	# The penalty for leaving the vision cone, will make the enemy prefer to target recently seen targets over close ones
	const chaseTimePenalty = 100
	for target in (cone_light.targets):
		# Score is caluclated as distance to target * chase time factor, which is lower the more recently the target was visible
		tmpScore = global_position.distance_to(target.global_position) + chaseTimePenalty * (1 - (cone_light.targets[target] / cone_light.chaseTime))
		if tmpScore < bestScore:
			bestScore = tmpScore
			best = target
	return best

# Remove targets that haven't been seen in a while
func update_available_targets(delta: float) -> void:
	for target in (cone_light.targets):
		if target:
			cone_light.targets[target] -= delta
			if cone_light.targets[target] < 0:
				target.chasing.erase(cone_light)
				cone_light.targets.erase(target)

# Update the alert level based on which agents are in the cone light
func update_alert(delta: float) -> void:
	# Use in_area here to only add alert when things are actively in the light
	if cone_light.in_area.size() > 0:
		for cow in cone_light.in_area:
			# Factor in distance and the minimum_followers of the agent into how much it increases alertness
			alert_level = min(max_alert * 2, alert_level + max(0,(range - global_position.distance_to(cow.global_position)) * cow.enemy_minimum_followers * delta))
	else:
		alert_level = max(0,alert_level - 50 * delta)
		
	if alert_level >= max_alert:
		current_state = State.CHASING
	elif alert_level >= min_alert:
		current_state = State.ALERT
	elif alert_level >= min_alert / 2:
		current_state = State.IDLE 
	else:
		current_state = State.PATROLLING

# Update the navigation target position, throw an error if state is invalid
func _update_target(delta: float) -> void:
	update_alert(delta)
	update_available_targets(delta)
	line.hide()
	idle_time += delta
	
	match current_state:
		State.PATROLLING:
			local_speed = 0.9
			# Calculate angle between patrol points
			cone_light.target_angle = (get_parent().path[(patrol_target-1)%get_parent().path_length].position - get_parent().path[patrol_target].position).angle()
			if !at_patrol_target:
				at_patrol_target = global_position.distance_to(navigation_agent_2d.target_position) < 20.0
				while idle_time >= idle_delay:
					idle_time -= idle_delay
				return
			while idle_time >= idle_delay:
				at_patrol_target = false
				patrol_target = (patrol_target + 1) % get_parent().path_length
				idle_time -= idle_delay
			navigation_agent_2d.target_position = get_parent().path[patrol_target].global_position
		State.ALERT:
			local_speed = 0.5
			
			while idle_time >= (idle_delay / 8.0):
				var best_target = get_best_target()
				if !best_target:
					current_state = State.IDLE 
					return
				# Get the closest unit (player or follower) to the enemy and wander towards it
				navigation_agent_2d.target_position = best_target.position + Vector2((randf()-0.5)*idle_distance/8, (randf()-0.5)*idle_distance/8)
				# Point the cone light towards the target
				cone_light.target_angle = (global_position - navigation_agent_2d.target_position).angle()
				idle_time -= idle_delay
		# Wander around idly
		State.IDLE:
			local_speed = 0.5
			while idle_time >= idle_delay:

				navigation_agent_2d.target_position = global_position + Vector2((randf()-0.5)*idle_distance, (randf()-0.5)*idle_distance)
				cone_light.target_angle = (position - navigation_agent_2d.target_position).angle()
				idle_time -= idle_delay
			
		# Chase the player
		State.CHASING:
			local_speed = 1.0
			var best_target = get_best_target()
			if !best_target:
				current_state = State.IDLE 
				return
			if global_position.distance_to(best_target.global_position) < range:
				shoot(best_target,delta)
				local_speed = 0.0
			else:
				navigation_agent_2d.target_position = best_target.position
		
		# If the state is invalid, throw an error
		var other:
			assert(false,"unexpected enemy state: " + State.keys()[other])

# Basic navigation code based on https://www.youtube.com/watch?v=7ZAF_fn3VOc
func navigate_to_target(delta: float) -> void:
	# Store the current position of the enemy in [current_agent_position]
	var current_agent_position = global_position
	
	# Get the next position along the path to the player
	var next_path_position = navigation_agent_2d.get_next_path_position()
	
	# Get the vector moving towards the next path position
	var new_velocity = local_speed * speed  * current_agent_position.direction_to(next_path_position)
	
	# Logic for when the enemy reaches the player (i.e. attack them)
	if navigation_agent_2d.is_navigation_finished():
		return
		
	# Apply the velocity to the enemy
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
		
	# Else calculate a "safe" velocity and apply that
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func _physics_process(delta: float) -> void:
	
	# Update where the enemy is targeting based on its state
	_update_target(delta)

	# Move towards the target, avoiding obsticals
	navigate_to_target(delta)

	move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
