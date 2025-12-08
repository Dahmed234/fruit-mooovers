
extends Node2D

@export var curve :Curve
@export var itemScene : PackedScene
var speed :float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	speed = 200 * randfn(1.3,0.25)
	
	var item : Carryable = itemScene.instantiate()
	add_child(item)
	var current_sprite = $Sprite2D/carrying
	var new_sprite: Sprite2D = item.getSpriteInfo()
	current_sprite.texture = new_sprite.texture
	current_sprite.region_rect = new_sprite.region_rect
	current_sprite.region_enabled = new_sprite.region_enabled
	current_sprite.position = $Sprite2D/head.position - item.bottom.position * 0.5
	current_sprite.global_scale = new_sprite.global_scale * 0.5
	
	
	item.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta  
	pass
