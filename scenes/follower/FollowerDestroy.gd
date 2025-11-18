extends RefCounted
class_name FollowerDestroy

var follower

func _init(_follower):
	follower = _follower


func start(item: Destroyable) -> void:
	var navigation_agent_2d = follower.navigation_agent_2d
	var label: Label = follower.label

	label.hide()

	item.onPickup(follower)

	# only main follower visible
	if item.main_follower != follower:
		follower.hide()
	else:
		follower.show()

	follower.currentState = follower.State.DESTROYING
	follower.carryingItem = item

	# snap above rock
	follower.global_position = item.global_position - Vector2(0.0, follower.ITEM_HEIGHT)

	# disable collision with other followers
	navigation_agent_2d.avoidance_mask = 0


func physics_update(delta: float) -> void:
	if follower.carryingItem:
		follower.global_position = follower.carryingItem.global_position \
			- Vector2(0.0, follower.ITEM_HEIGHT)
