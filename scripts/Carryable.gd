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

@export
var label: Label
# List of all carrying cows, stores in a set so O(1) time to add / remove carrying followers
var followersCarrying: Dictionary[CharacterBody2D,bool] = {}

#var carrying: CharacterBody2D

func getSpriteInfo() -> Sprite2D:
	return $Sprite2D

func onPickup(carrying: CharacterBody2D):
	if followersCarrying.is_empty():
		$CollisionShape2D.disabled = true
	followersCarrying[carrying] = true
	hide()


func onDrop(carrying: CharacterBody2D):
	followersCarrying.erase(carrying)
	if followersCarrying.is_empty():
		$CollisionShape2D.disabled = false
		show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "0/" + str(int(weight))
	print("I am an item",value,weight,global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if followersCarrying.size() > 0:
		position = followersCarrying.keys()[0].position
