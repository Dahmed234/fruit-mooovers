extends CharacterBody2D

## Damage dealt to target
var damage: float
## Damage dealt to target
var speed: float
## Number of degrees per second the projectile will home towards the target
var homing_factor: float
## The object that is being homed towards
var homing_target: CharacterBody2D

var proj: ProjectileResource

var direction: Vector2

var line = Line2D

var life_time: float

func _ready():
	speed =  proj.speed
	$Sprite2D.texture = proj.sprite
	homing_factor = proj.homing_factor
	life_time = proj.life_time



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
