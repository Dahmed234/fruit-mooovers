extends Control

@export var levelTime :Timer
var score :int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$clock.max_value = levelTime.wait_time


# Converts time to am/pm format
func amPm(s: String) -> String:
	var num_value = int(s)
	if  num_value >= 12: num_value -= 12
	if num_value == 0: return "12"
	assert(num_value <= 12,"Invalid hour")
	return str(num_value)

func leadingZero(s: String,length: int) -> String:
	while s.length() < length:
		s = "0" + s
	return s

# Gets the current time of day and updates the current day
func getTime() -> String:
	var fraction =  (levelTime.wait_time - levelTime.time_left) / levelTime.wait_time
	

	var time_hours := int(fraction * 24)
	var time_minutes := int(fraction * 24 * 60) - 60 * time_hours
	return amPm(str(time_hours)) + ":" + leadingZero(str(time_minutes),2) + ("am" if time_hours <= 11 else "pm")


func _process(_delta: float) -> void:
	if(levelTime.is_stopped()):
		$clock.hide()
	else:
		$clock.show()
		
		
	$ScoreLabel.text = "Score: %d" % score
		
	$clock.value = levelTime.time_left
	$Time.text = getTime()


func _on_throw_radius_num_throwable(num: Variant) -> void:
	$CowMeasure.update_current(num)
	pass # Replace with function body.


func _on_cow_amount_update(num) -> void:
	$CowMeasure.update_total(num)



func _on_score_update(newScore: int) -> void:
	score = newScore
	
