extends CharacterBody2D
class_name Projectile


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

func _ready():
	speed =  projectile_data.speed
	$Sprite2D.texture = projectile_data.sprite
	homing_factor = projectile_data.homing_factor
	life_time = projectile_data.life_time
	projectile_type = projectile_data.projectile_type

# handle special updates for projectiles, e.g. variables that should change or nonstandard movement.
func update(delta: float) -> void:
	match(projectile_type):
		ProjectileResource.ProjType.MISSILE:
			if life_time < 3*init_life_time/4:
				homing_factor = 5.0
				speed *= 3
		_:
			pass
func _physics_process(delta: float) -> void:
	if life_time < 0:
		die()
	life_time -= delta
	var target_direction = global_position.direction_to(homing_target.global_position)
	
	direction = Vector2.from_angle(lerp_angle(direction.angle(),target_direction.angle(),homing_factor * delta))
	
	velocity = direction * speed

	move_and_slide()



func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	
	# Set the target as in the area and being chased
	if other_shape_node.get_parent().get_parent():
		#print("clock strikes 12")
		#other_shape_node.get_parent().get_parent().damage(damage)
		pass

func die():
	queue_free()

static func launch(n_projectile: CharacterBody2D,pattern: AttackPattern, source: Vector2, target_pos: Vector2,target: CharacterBody2D):

	n_projectile.projectile_data = pattern.projectile_data
	# Get the direction to the target
	n_projectile.direction = source.direction_to(target_pos)
	# Apply random spread
	n_projectile.direction = Vector2.from_angle(
		randf_range(-pattern.projectile_spread/2,pattern.projectile_spread/2) +
		n_projectile.direction.angle()
	)
	
	n_projectile.homing_target = target
	
	return n_projectile
