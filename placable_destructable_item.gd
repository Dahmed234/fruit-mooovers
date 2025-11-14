extends Destroyable
signal requestDestroy(obj :Node2D)



# Used to get the follower that should be damaged when hit by enemy




@export
var max_health := 5.0
var current_health := max_health


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
	
	#root = get_node("/root/In Game")
	#carryFinished.connect(root.onCarryFinish)
	
	
	bar.fullColour = Color(0.5,0.5,0.5)
	bar.emptyColour = Color(0.5,0.5,0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	bar.fullness = (current_health) / max_health
	
	if current_health <= 0:
		destroy()
	else:
		current_health -= delta * min(2.0,followersCarrying.size()/ 2.0)
		# Set enemy to agro as soon as you start destroying it

func hasCapacity() -> bool:
	return true

func destroy():
	
	for cow in followersCarrying.keys():
		cow.stopCarrying()
		
	# request parent to destroy it : may need to update parent
	requestDestroy.emit(self)
