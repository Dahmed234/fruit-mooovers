extends CharacterBody2D



## Damage dealt to target
var damage: float
## Damage dealt to target
var speed: float

var source: Vector2
var destination: Vector2

func _physics_process(delta: float) -> void:
	velocity = source.direction_to(destination) * speed
	
	move_and_slide()
	
func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	
	# Set the target as in the area and being chased
	if other_shape_node.get_parent().get_parent():
		print("clock strikes 12")
		#other_shape_node.get_parent().get_parent().damage(damage)

func set_sprite(sprite: Texture2D):
	$Sprite2D.texture = sprite
