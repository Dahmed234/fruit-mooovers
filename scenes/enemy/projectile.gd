extends Area2D
class_name Projectile

const BEAM_MAX_RANGE = 10_000
const PROJECTILE = preload("uid://1352s7d3laj7")

## NOTE projectile sprites should be 64x64 or the hitbox will be the wrong size
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var root: Node2D

var pierced: Dictionary
## Damage dealt to target
var damage: float
## Damage dealt to target
var speed: float
## Number of degrees per second the projectile will home towards the target
var homing_factor: float
## The object that is being homed towards
var homing_target: CharacterBody2D

var pierce_left: int

var projectile_data: ProjectileResource

var direction: Vector2

var line = Line2D

var life_time: float
var init_life_time: float
var projectile_type: ProjectileResource.ProjType

var size: float

var expiration_attack: AttackPattern

var source: Vector2
## Store the enemy shooting the beam so that it moves with the enemy
var beam_emiitter: CharacterBody2D
var beam_sweep_angle
var beam_visual: Line2D

var particle_emitter: GPUParticles2D

func _ready():
	speed =  projectile_data.speed
	damage = projectile_data.damage
	$Sprite2D.texture = projectile_data.sprite
	homing_factor = projectile_data.homing_factor
	life_time = projectile_data.life_time
	init_life_time = life_time
	projectile_type = projectile_data.projectile_type
	expiration_attack = projectile_data.expiration_attack
	pierce_left = projectile_data.pierce
	global_position = source
	size = projectile_data.size
	scale = Vector2(size,size)
	
	sprite_2d.region_rect.size = Vector2(64,64)
	# Fix sprites pointing 90
	sprite_2d.rotation = PI/2
	
	root = get_node("/root/InGame")
	
	if projectile_data.particle_type:
		particle_emitter = projectile_data.particle_type.instantiate()
		root.add_child(particle_emitter)
	
	# Specific staring logic for some projectiles
	match(projectile_type):
		ProjectileResource.ProjType.EXPLOSION:
			scale = Vector2.ZERO
		ProjectileResource.ProjType.BEAM:
			sprite_2d.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

			sprite_2d.rotation += PI
			# Point in the initil sweep angle
			rotation = global_position.direction_to(homing_target.global_position).angle() - beam_sweep_angle / 2
		ProjectileResource.ProjType.REGULAR:
			modulate = Color(1,1,0)
		ProjectileResource.ProjType.MISSILE:
			modulate = Color(1,0,0)
			
func get_beam_length():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2.from_angle(rotation) * BEAM_MAX_RANGE,
		1, [self]
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	if result:
		return result.position.distance_to(global_position)
	else:
		return BEAM_MAX_RANGE
			
# handle special updates for projectiles, e.g. variables that should change or nonstandard movement.
func update(delta: float) -> void:
	if particle_emitter: particle_emitter.global_position = global_position
	match(projectile_type):
		ProjectileResource.ProjType.MISSILE:
			if life_time < 0.75 * init_life_time:
				homing_factor = 5.0
				speed = 500
		ProjectileResource.ProjType.EXPLOSION:
			# Get time (moves from 0 to 1 with lifetime
			var time = (init_life_time - life_time) / (init_life_time * 0.75)
			
			# Fade out explosion
			if time > 1:
				modulate.a = lerp(1,0,time - 1)
			time = min(time,1)
			# Scale up explosion until it reaches (1,1)
			scale = Vector2(time * size,time * size)
		ProjectileResource.ProjType.BEAM:
			var time = (init_life_time - life_time) / (init_life_time)
			if time > 0.25 and time < 0.75:
				rotation += delta * 2 * beam_sweep_angle / init_life_time
			
			var beam_length = get_beam_length()
			collision_shape_2d.scale = Vector2(beam_length / collision_shape_2d.shape.size.x,1)
			collision_shape_2d.position = Vector2(beam_length/2,0)
			sprite_2d.region_rect.size.y = beam_length
			sprite_2d.offset = Vector2(0,beam_length/2)
			
			global_position = beam_emiitter.global_position
			
				
		_:
			pass
			
func _physics_process(delta: float) -> void:
	if life_time < 0:
		die()
	life_time -= delta
	
	match (projectile_type):
		ProjectileResource.ProjType.BEAM:
			update(delta)
			
		_:
			update(delta)
			if homing_target:
				var target_direction = global_position.direction_to(homing_target.global_position)
		
				direction = Vector2.from_angle(lerp_angle(direction.angle(),target_direction.angle(),homing_factor * delta))
		
			rotation = direction.angle()
			
			global_position += direction * speed * delta


static func launch(n_projectile: Projectile,pattern: AttackPattern, n_source: Vector2, target_pos: Vector2,target: CharacterBody2D):

	n_projectile.projectile_data = pattern.projectile_data
	# Get the direction to the target
	n_projectile.direction = n_source.direction_to(target_pos)
	# Apply random spread
	n_projectile.direction = Vector2.from_angle(
		randf_range(-pattern.projectile_spread/2,pattern.projectile_spread/2) +
		n_projectile.direction.angle()
	)
	
	n_projectile.source = n_source
	
	n_projectile.homing_target = target
	
	return n_projectile


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and !pierced.get(body,false):
		body.damage(damage)
		pierced[body] = true
		#print(ProjectileResource.ProjType.keys()[projectile_type]," hit ",body.name)
		pierce_left -= 1
	if pierce_left <= 0:
		die()

func die():
	if particle_emitter: particle_emitter.emitting = false
	# Shoot new projectiles from final position when the projectile expires
	if expiration_attack:
		for i in range(expiration_attack.projectile_count):
			if is_instance_valid(homing_target):
				call_deferred("launch_death_projectile",homing_target)
			else:
				call_deferred("launch_death_projectile",null)
		
	# delete this projectile
	call_deferred("queue_free")

func launch_death_projectile(n_homing_target):
	get_parent().owner.add_child(launch(
		PROJECTILE.instantiate(),
		expiration_attack,
		global_position,
		Vector2.RIGHT,
		n_homing_target
	))
