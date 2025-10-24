extends StaticBody2D

class_name Carryable


@export
var value: int

# Cows rewarded by the item
@export
var followerValue: int

# Weight of the item, defines how many cows are needed to carry it
@export 
var weight: float

var followersCarrying := 0.0

func getSpriteInfo() -> Sprite2D:
	return $Sprite2D

func onPickup():
	#queue_free()
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
