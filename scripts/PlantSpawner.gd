extends Node2D

@export
var item: PackedScene

@onready var label: Label = $"../UI/Control/Label"

var sprites : Dictionary[String,Vector2] = {
	"apple" : Vector2(528,288),
	"pear" : Vector2(544,288),
	"cheese" : Vector2(544,256),
	"fish" : Vector2(528,272),
	"meat" : Vector2(528,256)
}


var value: float
var followerValue: float
var weight: float
var sprite: String
var currentItem

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	spawn(0)
	label.respawnObjects.connect(spawn)

func spawn(day):
	if !currentItem:
		var nItem = item.instantiate()
		currentItem = nItem
		nItem.value = value
		nItem.followerValue = followerValue
		nItem.weight = weight
		nItem.global_position = global_position
		# Set the position on the sprite sheet to the correct sprite, or default to "apple"
		nItem.find_child("Sprite2D").region_rect.position = sprites[sprite if sprite else "apple"] 
		get_parent().add_child(nItem)
