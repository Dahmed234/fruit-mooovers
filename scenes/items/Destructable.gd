extends Interactable
class_name Destroyable

# Used to get the follower that should be damaged when hit by enemy (still via main_follower from base)

@export var isEnemy := false

@export var lifespan := 5.0
var time := 0.0

@onready var bar: Node2D = $Bar

signal requestDestroy(obj :Node2D)

func _ready() -> void:
	super._ready()

	if isEnemy:
		$CollisionShape2D.disabled = true
	else:
		bar.fullColour = Color(0.5, 0.5, 0.5)
		bar.emptyColour = Color(0.5, 0.5, 0.5)


func _physics_process(delta: float) -> void:
	# Progress bar for destruction
	bar.fullness = (lifespan - time) / lifespan

	# Label is automatically updated by Interactable when followers change

	if time > lifespan:
		destroy()
	elif followersCarrying.size() >= minimum_followers:
		# Destruction speed scales with number of followers
		time += delta * followersCarrying.size()

		if isEnemy:
			get_parent().alert_level = get_parent().max_alert * 2
			get_parent().update_alert(delta)
	else:
		# optional: idle visual feedback
		pass


func destroy() -> void:
	if isEnemy:
		get_parent().die()

	# Make all followers stop carrying this and go back to their own logic
	dropAll()
	requestDestroy.emit(self)
	queue_free()
