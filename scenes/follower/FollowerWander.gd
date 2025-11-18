extends RefCounted
class_name FollowerWander

var follower

func _init(_follower):
	follower = _follower


func start() -> void:
	follower.show()
	follower.timer.start(
		follower.TIMERLENGTH + follower.TIMERVARIANCE * randf_range(-1, 1)
	)
	follower.currentState = follower.State.WANDER
	on_timeout()


func end() -> void:
	follower.direction = Vector2.ONE
	follower.velocity = Vector2.ZERO
	follower.timer.stop()


func on_timeout() -> void:
	var navigation_agent_2d = follower.navigation_agent_2d
	var player = follower.player

	var direction = follower.direction.normalized()
	var old_direction = direction

	# random direction
	direction.x = randf_range(-1, 1)
	direction.y = randf_range(-1, 1)
	direction = direction.normalized()

	# bias to previous direction
	direction = direction.lerp(old_direction, randf())

	# if too far from player, walk back towards them
	if follower.global_position.distance_to(player.global_position) > follower.wanderDistance:
		direction = follower.global_position.direction_to(player.global_position)

	follower.currentspeed = follower.BASESPEED + follower.SPEEDVARIANCE * randf_range(-1, 1)
	follower.direction = direction

	navigation_agent_2d.target_position = follower.global_position \
		+ direction * follower.currentspeed * follower.TIMERLENGTH / 2.0

	follower.timer.start(
		follower.TIMERLENGTH + follower.TIMERVARIANCE * randf_range(-1, 1)
	)
