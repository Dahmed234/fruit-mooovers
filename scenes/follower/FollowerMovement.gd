extends RefCounted
class_name FollowerMovement

var follower :Follower

func _init(_follower):
	follower = _follower


func navigate_to_target(delta: float) -> void:
	var navigation_agent_2d = follower.navigation_agent_2d

	if navigation_agent_2d.is_navigation_finished():
		return

	var local_velocity: float
	var carrying_item = follower.carryingItem
	var current_state = follower.currentState

	if not carrying_item:
		match current_state:
			follower.State.WANDER:
				local_velocity = 0.5
			_:
				local_velocity = 1.0
	else:
		if carrying_item.followersCarrying.size() >= carrying_item.minimum_followers:
			# Speed while carrying
			local_velocity = 0.4 * min(
				2.0,
				carrying_item.followersCarrying.size() / carrying_item.minimum_followers / 1.3
				
			)
		else:
			# Too heavy -> don't move
			local_velocity = 0.0

	var current_agent_position = follower.global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = local_velocity \
		* follower.currentspeed \
		* current_agent_position.direction_to(next_path_position)

	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		follower._on_navigation_agent_2d_velocity_computed(new_velocity)
