extends StaticBody2D

class_name Destroyable
@export
# The tilemap position of this tile
var tilePos: Vector2i
# The tilemap layer we are looking at
@export
var tileMap: TileMapLayer
@export
var navMap: TileMapLayer
@export
var lifespan := 5.0
var time := 0.0

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if time > lifespan:
		destroy()
	else:
		time += delta * min(2.0,followersCarrying.size() / weight / 2.0)

func destroy():
	tileMap.set_cell(tilePos,1)
	#call_deferred("update_nav")
	#update_nav()
	
	
	for cow in followersCarrying.keys():
		cow.stopCarrying()
	
	queue_free()

#func update_nav():
	#navMap.notify_runtime_tile_data_update()
	#var nav_map = navMap.get_navigation_map()
