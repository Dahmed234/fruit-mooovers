extends "res://scenes/enemy/enemy.gd"

const PROJECTILE = preload("uid://1352s7d3laj7")


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export
var pathPoint :PathFollow2D 

@export var DIST_THRESHOLD :float

@export var attack_patterns: Array[AttackPattern]
var attack_pattern_index := 0
var attack_time: float = 0.0
var attack_count: int = 0
var direction:int = 1

var path :Curve2D

var best_target: CharacterBody2D



func _ready():
	await get_tree().process_frame
	await get_tree().physics_frame
	global_position = pathPoint.global_position
	path = get_parent().curve
	super()

func _next_attack_pattern():
	
	attack_pattern_index = (attack_pattern_index + 1) % len(attack_patterns)
	
	
	
	attack_time = 0.0
	attack_count = 0

func _shoot(target: CharacterBody2D,pattern: AttackPattern):
	attack_count += 1


	var n_proj = Projectile.launch(PROJECTILE.instantiate(),pattern,global_position,target.global_position,target)
	
	# Beam attack needs to feed the spread to the projectile directly as it has atypical behaviour
	match (pattern.projectile_data.projectile_type):
		ProjectileResource.ProjType.BEAM:
			n_proj.beam_sweep_angle = pattern.projectile_spread
			n_proj.beam_emiitter = self

	owner.add_child(n_proj)

func _update_target(delta: float) -> void:
	update_alert(delta)
	update_available_targets(delta)
	line.hide()
	idle_time += delta
	
	match current_state:
		State.PATROLLING:
			local_speed = 0.9

			if(global_position.distance_to(pathPoint.global_position)) < DIST_THRESHOLD:
				pathPoint.advance(SPEED /10)
				
			navigation_agent_2d.target_position = pathPoint.global_position
			
			
			$"Cone light".target_angle= Vector2.LEFT.angle_to(velocity)
		State.ALERT:
			local_speed = 0.5
			
			while idle_time >= (idle_delay / 8.0):
				best_target = get_best_target()
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
			best_target = get_best_target()
			if !best_target:
				current_state = State.IDLE 
				return
			if global_position.distance_to(best_target.global_position) < attack_range:
				
				current_state = State.ATTACKING
				_update_target(delta)
				attack_best_target()
			else:
				navigation_agent_2d.target_position = best_target.position

		State.ATTACKING:
			
			if !attack_patterns: 
				assert(false,"Enemy has no attack patterns but wants to attack, no patterns :(")
			var pattern: AttackPattern = attack_patterns[attack_pattern_index]
			attack_time += delta
			
			# Move to next attack if all 3 phases done
			if (attack_time > pattern.windup + pattern.attack_time + pattern.cooldown):
				# Logic for moving to the next attack
				_next_attack_pattern()
				attack_best_target()
				
				
				
				# Stop attacking when the current attack is finished and there are no nearby targets
				if !best_target or global_position.distance_to(best_target.global_position) > attack_range * 1.5:
					current_state = State.CHASING
			
			# try to shoot if the windup is done
			elif (attack_time > pattern.windup and attack_time <  pattern.windup + pattern.attack_time):
				
				while (pattern.projectile_count *
					((attack_time - pattern.windup) / 
					pattern.attack_time) > attack_count
				):
					# Pick a new target if the current one dies
					if !is_instance_valid(best_target):
						attack_best_target()
					# Shoot if the newly picked target exists (i.e. there is something to shoot at)
					if best_target:
						_shoot(best_target,pattern)
				
				
			# else do the windup animation (indicate that the enmy will shoot soon)
			else:
				pass
		# If the state is invalid, throw an error
		var other:
			assert(false,"unexpected enemy state: " + State.keys()[other])

func attack_best_target():
	#if is_instance_valid(best_target):
		#best_target.modulate = Color(1,1,1,)
	best_target = get_best_target()
	#if best_target:
		#best_target.modulate = Color(1,0,0)

func _process(delta: float) -> void:
	if !is_ready: 
		return
	# Update where the enemy is targeting based on its state
	_update_target(delta)

	# Move towards the target, avoiding obsticals
	navigate_to_target(delta)

	move_and_slide()
