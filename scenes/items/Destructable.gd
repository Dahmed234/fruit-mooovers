extends Interactable

class_name Destroyable

signal carryFinished(item: Destroyable)

# Used to get the follower that should be damaged when hit by enemy (still via main_follower from base)

@export
var tilePos: Vector2i
@export var tileMap: TileMapLayer
@export var navMap: TileMapLayer

@export var isEnemy := false

@export var lifespan := 5.0
var time := 0.0

var root

@onready var bar: Node2D = $Bar


func _ready() -> void:
	super._ready()

	root = get_node("/root/In Game")
	carryFinished.connect(root.onCarryFinish)

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
	elif followersCarrying.size() >= weight:
		# Destruction speed scales with number of followers
		time += delta * min(2.0, followersCarrying.size() / weight / 2.0)

		if isEnemy:
			get_parent().alert_level = get_parent().max_alert * 2
			get_parent().update_alert(delta)
	else:
		# optional: idle visual feedback
		pass


func destroy() -> void:
	carryFinished.emit(self, global_position)

	if isEnemy:
		get_parent().die()
	else:
		tileMap.set_cell(tilePos, 1)
		navMap.notify_runtime_tile_data_update()

	# Make all followers stop carrying this and go back to their own logic
	dropAll()

	queue_free()
