extends Label

signal respawnObjects(day)
# The game-over scene, is loaded right before switching scenes because of weirdness that was caused by loaded at ready time
var gameOver: Node2D

@export
# Day length in seconds
var day_length := 120.0

@export
# Amount of points needed per day to continue
# Initial value is set here, then increases exponentially with time
var quota := 100

@export 
# Chooses the format for displaying the ingame time
var isAmPm: bool = true

# Initial score, total score is the same as score but doesn't go down with quota
var score := 0
var totalScore := 0
var cowScore := 1

var initialWindowSize: Vector2

# The current day, updates every time 24 in game hours pass
var day := 0

# Represents ingame time passed in seconds, updates by adding delta in the process stage
var time : float

# Adds leading zeros to time, where length defines how many zeros are needed
func leadingZero(s: String,length: int) -> String:
	while s.length() < length:
		s = "0" + s
	return s

# Converts time to am/pm format
func amPm(s: String) -> String:
	var num_value = int(s)
	if  num_value >= 12: num_value -= 12
	if num_value == 0: return "12"
	assert(num_value <= 12,"Invalid hour")
	return str(num_value)

# Converts time to 24h format
func t4h(s: String) -> String:
	var num_value = int(s)
	assert(num_value <= 24,"Invalid hour")
	return leadingZero(s,2)

# Gets the current time of day and updates the current day
func getTime() -> String:
	var fraction = time / day_length
	# Call newday one time when a new day starts
	if int(fraction * 24) - 24 * day > 23:
		newDay()
	day = int(fraction)
	var time_hours := int(fraction * 24) - 24 * day
	var time_minutes := int(fraction * 24 * 60) - 60 * time_hours - 24 * 60 * day
	if isAmPm:
		return amPm(str(time_hours)) + ":" + leadingZero(str(time_minutes),2) + ("am" if time_hours <= 11 else "pm")
	else:
		return t4h(str(time_hours)) + ":" + leadingZero(str(time_minutes),2)

# Logic to go back to main menu, reset score etc
func restartGame():
	gameOver = load("res://scenes/GameOver.tscn").instantiate()
	gameOver.label.text = "Game Over
	Score: " + str(totalScore) + "
	Total cows: " + str(cowScore)
	get_tree().root.add_child(gameOver)
	# ../../.. is the current root, which we free and replace with the gameOver scene root
	$"../../..".queue_free()

# Function for how fast to increase quota, should have some kind of exponential scaling
func increaseQuota():
	quota += quota / 2

# Check if the player met quota by the end of the day
func newDay() -> void:
	# If the score is too low, the player has lost and should go back to the main menu
	if false:#score < quota: 
		restartGame()
	# If quota is met, deduct those points and increase the quota
	else:
		score -= quota
		increaseQuota()
		respawnObjects.emit(day)
		print("met quota")

# Update the score, quota, day and time
func _process(delta: float) -> void:
	time += delta
	text = "Score: "  +  str(score) + " / " + str(quota) + "
	Day: " + str(day+1) + "
	Time: " + getTime()

func _ready():
	#get_parent().get_parent().scale = Vector2.ONE / get_parent().get_parent().zoom
	# Sort out dynamic UI placement to handle window size changing
	initialWindowSize = get_viewport().get_visible_rect().size


func _on_player_player_dies() -> void:
	restartGame()
