extends StaticBody2D



class_name Destroyable

# Used to get the follower that should be damaged when hit by enemy
var main_follower = null


@export
# The tilemap position of this tile
var tilePos: Vector2i
# The tilemap layer we are looking at (destructable walls layer
@export var tileMap: TileMapLayer# = $"Destructible walls"
@export var navMap: TileMapLayer# = $Ground

@export var isEnemy := false

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

@onready var bar: Node2D = $Bar


func getSpriteInfo() -> Sprite2D:
	return $Sprite2D

func onPickup(carrying: CharacterBody2D):
	followersCarrying[carrying] = true


func dropAll(dead):
	for cow in followersCarrying.keys():
		cow.stopCarrying()
		
	followersCarrying.erase(dead)

func onDrop(carrying: CharacterBody2D):
	followersCarrying.erase(carrying)
	main_follower = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "0/" + str(int(weight))
	
	if isEnemy: 
		$CollisionShape2D.disabled = true
	else:
		bar.fullColour = Color(0.5,0.5,0.5)
		bar.emptyColour = Color(0.5,0.5,0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	bar.fullness = (lifespan - time) / lifespan
	
	label.text = str(int(followersCarrying.size())) + "/" + str(int(weight))
	
	if time > lifespan:
		destroy()
	elif followersCarrying.size() >= weight:
		time += delta * min(2.0,followersCarrying.size() / weight / 2.0)
		# Set enemy to agro as soon as you start destroying it
		if isEnemy:
			get_parent().alert_level = get_parent().max_alert * 2
			get_parent().update_alert(delta)
	else:
		# do some animation to show nothing is happening
		pass
	

func hasCapacity() -> bool:
	return followersCarrying.size() < weight*2

func destroy():
	
	# Logic for if is enemy / tile
	if isEnemy:
		get_parent().die()
	else:
		tileMap.set_cell(tilePos,1)
		navMap.notify_runtime_tile_data_update()
	
	for cow in followersCarrying.keys():
		cow.stopCarrying()
	
	
	queue_free()
