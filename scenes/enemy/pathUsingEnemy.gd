extends "res://scenes/enemy/enemy.gd"


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export
var pathPoint :PathFollow2D 

const PROJECTILE = preload("uid://1352s7d3laj7")

@export var DIST_THRESHOLD :float

@export var attack_patterns: Array[AttackPattern]
var attack_pattern_index := 0
var attack_time: float = 0.0
var attack_count: int = 0
var direction:int = 1

var path :Curve2D

func _ready():
	global_position = pathPoint.global_position
	path = get_parent().curve
	
	super()

func _next_attack_pattern():
	print("changed pattern")
	attack_pattern_index = (attack_pattern_index + 1) % len(attack_patterns)
	
	attack_time = 0.0
	attack_count = 0

func _shoot(target: CharacterBody2D,pattern: AttackPattern):
	attack_count += 1
	var n_projectile = PROJECTILE.instantiate()
	#@export var damage: float
### Damage dealt to target
#@export var speed: float
### Sprite to render
#@export var sprite: Texture2D
### Radius of collision box
#@export var size: float
	n_projectile.damage = pattern.projectile_type.damage
	n_projectile.speed =  pattern.projectile_type.speed
	n_projectile.set_sprite(pattern.projectile_type.sprite)
	n_projectile.source = global_position
	n_projectile.destination = target.global_position
	add_child(n_projectile)
	print("shoot!")

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
				current_state = State.ATTACKING
				_update_target(delta)
			else:
				navigation_agent_2d.target_position = best_target.position

		State.ATTACKING:
			if !attack_patterns: 
				assert(false,"no patterns :(")
			var pattern: AttackPattern = attack_patterns[attack_pattern_index]
			attack_time += delta
			
			if (attack_time > pattern.attack_time):
				_next_attack_pattern()
			
			else:
				var best_target = get_best_target()
				if !best_target: return
				while (attack_count < pattern.projectile_count * (attack_time / pattern.attack_time)):
					_shoot(best_target,pattern)
				if global_position.distance_to(best_target.global_position) > range * 2:
					current_state = State.CHASING
			
		# If the state is invalid, throw an error
		var other:
			assert(false,"unexpected enemy state: " + State.keys()[other])

func _physics_process(delta: float) -> void:
	
	# Update where the enemy is targeting based on its state
	_update_target(delta)

	# Move towards the target, avoiding obsticals
	navigate_to_target(delta)

	move_and_slide()
