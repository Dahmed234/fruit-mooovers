extends Label


var score := 0
# Amount of points needed per day to not lose
var quota := 100

var day := 1

# Represents ingame time in seconds
var time : float

# Day length in seconds
var day_length := 30.0
	
func changeScore(change :int):
	score += change
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func leadingZero(s: String,length: int) -> String:
	while s.length() < length:
		s = "0" + s
	return s

func amPm(s: String) -> String:
	var num_value = int(s)
	if  num_value >= 12: num_value -= 12
	if num_value == 0: return "12"
	assert(num_value <= 12,"Invalid hour")
	return str(num_value)

func getTime() -> String:
	var fraction = time / day_length
	# Call newday one time when a new day starts
	if int(fraction * 24) - 24 * day > 23:
		newDay()
	day = int(fraction)
	var time_hours := int(fraction * 24) - 24 * day
	var time_minutes := int(fraction * 24 * 60) - 60 * time_hours - 24 * 60 * day
	
	return amPm(str(time_hours)) + ":" + leadingZero(str(time_minutes),2) + ("am" if time_hours <= 11 else "pm")

# Logic to go back to main menu, reset score etc
func restartGame():
	print("you lose!!!!!!!!!")
	
# Function for how fast to increase quota, should have some kind of exponential scaling
func increaseQuota():
	quota += quota / 2

# Check if the player met quota by the end of the day
func newDay() -> void:
	# If the score is too low, the player has lost and should go back to the main menu
	if score < quota: restartGame()
	# If quota is met, deduct those points and increase the quota
	else:
		score -= quota
		increaseQuota()
		print("met quota")
	
# Update the score, quota, day and time
func _process(delta: float) -> void:
	time += delta
	text = "Score: "  +  str(score) + " / " + str(quota) + "
	Day: " + str(day+1) + "
	Time: " + getTime()
