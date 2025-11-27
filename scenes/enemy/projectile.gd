extends Area2D
class_name Projectile

const PROJECTILE = preload("uid://1352s7d3laj7")

## Damage dealt to target
var damage: float
## Damage dealt to target
var speed: float
## Number of degrees per second the projectile will home towards the target
var homing_factor: float
## The object that is being homed towards
var homing_target: CharacterBody2D

var projectile_data: ProjectileResource

var direction: Vector2

var line = Line2D

var life_time: float
var init_life_time: float
var projectile_type: ProjectileResource.ProjType

var expiration_attack: AttackPattern

var source: Vector2

func _ready():
	speed =  projectile_data.speed
	damage = projectile_data.damage
	$Sprite2D.texture = projectile_data.sprite
	homing_factor = projectile_data.homing_factor
	life_time = projectile_data.life_time
	init_life_time = life_time
	projectile_type = projectile_data.projectile_type
	expiration_attack = projectile_data.expiration_attack
	global_position = source

# handle special updates for projectiles, e.g. variables that should change or nonstandard movement.
func update(delta: float) -> void:
	match(projectile_type):
		ProjectileResource.ProjType.MISSILE:
			if life_time < 0.75 * init_life_time:
				homing_factor = 5.0
				speed = 500
		_:
			pass
func _physics_process(delta: float) -> void:
	if life_time < 0:
		die()
	life_time -= delta
	
	# Change targeting variables / speed mid flight
	update(delta)
	
	if homing_target:
		var target_direction = global_position.direction_to(homing_target.global_position)
	
		direction = Vector2.from_angle(lerp_angle(direction.angle(),target_direction.angle(),homing_factor * delta))
	
	global_position += direction * speed * delta



static func launch(n_projectile: Projectile,pattern: AttackPattern, source: Vector2, target_pos: Vector2,target: CharacterBody2D):

	n_projectile.projectile_data = pattern.projectile_data
	# Get the direction to the target
	n_projectile.direction = source.direction_to(target_pos)
	# Apply random spread
	n_projectile.direction = Vector2.from_angle(
		randf_range(-pattern.projectile_spread/2,pattern.projectile_spread/2) +
		n_projectile.direction.angle()
	)
	
	n_projectile.source = source
	
	n_projectile.homing_target = target
	
	return n_projectile


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.damage(damage)
	die()

func die():
	# Shoot new projectiles from final position when the projectile expires
	if expiration_attack:
		for i in range(expiration_attack.projectile_count):
			get_parent().owner.add_child(launch(
				PROJECTILE.instantiate(),
				expiration_attack,
				global_position,
				Vector2.RIGHT,homing_target
			))
		
	# delete this projectile
	queue_free()
