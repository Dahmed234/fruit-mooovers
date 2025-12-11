extends RefCounted
class_name FollowerDestroy

var follower :Follower

func _init(_follower):
	follower = _follower

var point : Vector2
func start(item: Destroyable) -> void:
	var navigation_agent_2d = follower.navigation_agent_2d
	var label: Label = follower.label

	label.hide()

	item.onPickup(follower)

	## only main follower visible
	#if item.main_follower != follower:
		#follower.hide()
	#else:
		#follower.show()

	follower.currentState = follower.State.DESTROYING
	follower.carryingItem = item

	## snap to valid space on  nav map
	
	point =NavigationServer2D\
		.map_get_closest_point(
			follower.navigation_agent_2d.get_navigation_map(),
			follower.global_position
		)

	follower.global_position = point

	# disable collision with other followers
	navigation_agent_2d.avoidance_mask = 0


func physics_update(_delta: float) -> void:
	pass
	#if follower.carryingItem:
		#follower.global_position = point
