extends Node2D

@export
var item: PackedScene

var sprites : Dictionary[String,Vector2] = {
	"apple" : Vector2(528,288),
	"pear" : Vector2(544,288),
	"cheese" : Vector2(544,256),
	"fish" : Vector2(528,272),
	"meat" : Vector2(528,256)
}



var value: float
var followerValue: float
var minimum_followers: float
var sprite: String
var currentItem = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	$Sprite2D.hide()
	spawn(0)
	
	## this is bad and defeats the purpose of signals :/ 
	## bro should NOT know  abt the label thats labels job
	#label.respawnObjects.connect(spawn)

func spawn(day):
	if !currentItem:
		var nItem = item.instantiate()
		currentItem = nItem
		#nItem.value = value
		#nItem.followerValue = followerValue
		#nItem.minimum_followers = minimum_followers
		nItem.global_position = global_position
		# Set the position on the sprite sheet to the correct sprite, or default to "apple"
		# Item.find_child("Sprite2D").region_rect.position = sprites[sprite if sprite else "apple"] 
		get_parent().add_child.call_deferred(nItem)
