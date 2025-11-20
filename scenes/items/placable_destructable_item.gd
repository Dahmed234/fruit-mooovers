extends Destroyable




signal requestDestroy(obj :Node2D)



# Used to get the follower that should be damaged when hit by enemy




@export
var max_health := 5.0

@onready
var current_health := max_health

@export # minimum amount of followers required to break this item
var minimum_followers = 0


func getSpriteInfo() -> Sprite2D:
	return $Sprite2D


func onDrop(carrying: CharacterBody2D):
	followersCarrying.erase(carrying)
	main_follower = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#root = get_node("/root/In Game")
	#carryFinished.connect(root.onCarryFinish)
	
	$Label.text = str(minimum_followers)
	
	
	bar.fullColour = Color(0.5,0.5,0.5)
	bar.emptyColour = Color(0.5,0.5,0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	bar.fullness = (current_health) / max_health
	
	
	# change label contents based on amount of followers
	$Label.text = str(clamp(minimum_followers - followersCarrying.size(),0,minimum_followers))
	
	if(minimum_followers <= followersCarrying.size()):
		$Label.hide()
	else:
		$Label.show()
	
	
	
	if current_health <= 0:
		destroy()
	else:
		if(minimum_followers <= followersCarrying.size()):
			current_health -= delta * min(2.0,followersCarrying.size()/ 2.0)
		# Set enemy to agro as soon as you start destroying it

func hasCapacity() -> bool:
	return true

func destroy():
	
	dropAll()
		
	# request parent to destroy it : may need to update parent
	requestDestroy.emit(self)
