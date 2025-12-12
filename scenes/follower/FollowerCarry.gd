extends RefCounted
class_name FollowerCarry

var follower

func _init(_follower):
	follower = _follower


func start(item: Carryable) -> void:
	var navigation_agent_2d = follower.navigation_agent_2d
	var label: Label = follower.label
	var held_item = follower.get_node("Sprite2D/heldItem")

	held_item.show()
	held_item.modulate = Color(1, 1, 1)
	label.show()

	follower.currentState = follower.State.CARRYING

	# setup sprite
	var current_sprite: Sprite2D = held_item.get_node("Sprite")
	var new_sprite: Sprite2D = item.getSpriteInfo()
	current_sprite.texture = new_sprite.texture
	current_sprite.region_rect = new_sprite.region_rect
	current_sprite.region_enabled = new_sprite.region_enabled
	current_sprite.global_scale = new_sprite.global_scale
	current_sprite.position= held_item.position - item.bottom.position

	navigation_agent_2d.avoidance_mask = 0

	follower.carryingItem = item

	# snap to item
	follower.global_position = item.global_position
	label.position.y = 10.0

	item.onPickup(follower)

	# Only main follower visible while carrying
	if item.main_follower != follower:
		follower.hide()
	else:
		follower.show()

	navigation_agent_2d.target_position = follower.goal.global_position


func physics_update(delta: float) -> void:
	var item = follower.carryingItem
	if not item:
		return

	if item.main_follower != follower:
		follower.global_position = item.global_position
		return

	var navigation_agent_2d = follower.navigation_agent_2d
	var label: Label = follower.label

	label.text = str(int(item.followersCarrying.size())) \
		+ "/" + str(int(item.minimum_followers))
	
	if(item.followersCarrying.size() < item.minimum_followers):
		label.modulate = Color.ORANGE
	elif  (item.followersCarrying.size() >= item.maximum_followers):
		label.modulate = Color.AQUA
	else:
		label.modulate = Color.GREEN

	if navigation_agent_2d.is_target_reached():
		var tmp = item
		# Make all followers drop this item when the destination is reached
		if tmp and tmp.has_method("dropAll"):
			tmp.dropAll()
		follower.carryFinished.emit(tmp, follower.position)
	else:
		navigation_agent_2d.target_position = follower.goal.global_position
		follower.movement.navigate_to_target(delta)


func stop() -> void:
	var navigation_agent_2d = follower.navigation_agent_2d
	var held_item = follower.get_node("Sprite2D/heldItem")
	var label: Label = follower.label

	follower.show()
	held_item.hide()
	label.hide()
	follower.velocity = Vector2.ZERO

	if follower.carryingItem:
		var item = follower.carryingItem
		follower.carryingItem = null
		if item.has_method("onDrop"):
			item.onDrop(follower)

	navigation_agent_2d.avoidance_mask = 1
