extends StaticBody2D

class_name Interactable

signal carry_started(follower: CharacterBody2D)
signal carry_stopped(follower: CharacterBody2D)

@export var value: int
@export var followerValue: int
@export var minimum_followers: int = 1;
@export var maximum_followers: int = 1;
@export var label: Label

# Followers currently carrying this item.
# IMPORTANT: This is now an ARRAY, not a Dictionary.
# The follower at index 0 is always considered the main follower.
var followersCarrying: Array[CharacterBody2D] = []
var main_follower: CharacterBody2D = null


func _ready() -> void:
	_update_label()


func getSpriteInfo() -> Sprite2D:
	return $Sprite2D


func hasCapacity() -> bool:
	return maximum_followers < 0 || followersCarrying.size() < maximum_followers


func onPickup(follower: CharacterBody2D) -> void:
	if followersCarrying.has(follower):
		return

	followersCarrying.append(follower)

	# First follower becomes the main follower
	if followersCarrying.size() == 1:
		main_follower = follower
		_on_first_follower_added()

	_update_label()
	carry_started.emit(follower)


func onDrop(follower: CharacterBody2D) -> void:
	if !followersCarrying.has(follower):
		return

	var was_main := (main_follower == follower)
	followersCarrying.erase(follower)

	if followersCarrying.is_empty():
		main_follower = null
		_on_no_followers_left()
	elif was_main:
		# Promote next follower as main
		main_follower = followersCarrying[0]
		_on_main_follower_changed(main_follower)

	_update_label()
	carry_stopped.emit(follower)


# Drop all followers (used when finishing carrying / destroying)
# Everyone stops carrying and returns to their own state.
func dropAll(excluded: CharacterBody2D = null) -> void:
	for cow in followersCarrying.duplicate():
		if cow == excluded:
			continue
		if cow.has_method("stopCarrying"):
			cow.stopCarrying()
	# followersCarrying will be updated by onDrop() calls
	# triggered inside stopCarrying()


# Hook: called when the FIRST follower starts carrying this
func _on_first_follower_added() -> void:
	# Override in child classes if needed
	pass


# Hook: called once the LAST follower has dropped / died
func _on_no_followers_left() -> void:
	# Override in child classes if needed
	pass


# Hook: called when main follower changes (e.g. previous main died/dropped)
func _on_main_follower_changed(new_main: CharacterBody2D) -> void:
	if new_main and new_main.has_method("on_become_main_follower"):
		new_main.on_become_main_follower(self)


func _update_label() -> void:
	if label and minimum_followers > 0.0:
		label.text = "%d/%d" % [followersCarrying.size(), minimum_followers]
