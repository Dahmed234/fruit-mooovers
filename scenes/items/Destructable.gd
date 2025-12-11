extends Interactable
class_name Destroyable

# Used to make health bar smoother
var health_bar_smoothing = 10

# Used to get the follower that should be damaged when hit by enemy (still via main_follower from base)

@export var isEnemy := false

@export var lifespan := 5.0
var time := 0.0

#@onready var bar: Node2D = $Bar
@onready var health: TextureProgressBar = $Sprite2D/Health

signal requestDestroy(obj :Node2D)


@export
var north = true

@export
var east = true

@export
var south =true 

@export
var west = true 

func _ready() -> void:
	super._ready()
	$Area2D/North.disabled = !north
	$Area2D/East.disabled = !east
	$Area2D/South.disabled = !south
	$Area2D/West.disabled = !west
	

	if isEnemy:
		$CollisionShape2D.disabled = true
		$Label.hide()
	else:
			
		$Area2D/East/EdenySprite.visible = !east
		$Area2D/North/NdenySprite.visible = !north
		$Area2D/West/WdenySprite.visible =!west
		$Area2D/South/SdenySprite.visible = !south
		
		$"Sprite2D/Health".max_value = lifespan * health_bar_smoothing

func _physics_process(delta: float) -> void:
	# Progress bar for destruction
	health.value = (float(lifespan) - float(time)) * health_bar_smoothing

	# Label is automatically updated by Interactable when followers change

	if time > lifespan:
		for follower in followersCarrying:
			if follower and is_instance_valid(follower):
				destroy(follower)
				return
		destroy(null)
	elif followersCarrying.size() >= minimum_followers:
		# Destruction speed scales with number of followers
		time += delta * followersCarrying.size()

		if isEnemy:
			get_parent().alert_level = get_parent().max_alert * 2
			get_parent().update_alert(delta)
	else:
		# optional: idle visual feedback
		pass

func move_followers(amount: Vector2):
	for follower in followersCarrying:
		if follower and is_instance_valid(follower):
			follower.global_position += amount

func destroy(follower) -> void:
	if isEnemy:
		get_parent().die()
	
	if follower:
		follower.carryFinished.emit(self, self.global_position)
	# Make all followers stop carrying this and go back to their own logic
	dropAll()
	requestDestroy.emit(self)
	
	queue_free()
