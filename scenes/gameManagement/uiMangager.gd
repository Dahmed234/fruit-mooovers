extends Control

@export var levelTime :Timer
var score :int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$clock.max_value = levelTime.wait_time
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(levelTime.is_stopped()):
		$clock.hide()
	else:
		$clock.show()
		
		
	$ScoreLabel.text = "Score: %d" % score
		
	$clock.value = levelTime.time_left
	var textTime
	if (levelTime.time_left as int / 60) > 0:
		$Time.text = str(levelTime.time_left as int / 60)
	else:
		$Time.text = str(levelTime.time_left as int % 60)
	pass


func _on_throw_radius_num_throwable(num: Variant) -> void:
	$CowMeasure.update_current(num)
	pass # Replace with function body.


func _on_cow_amount_update(num) -> void:
	$CowMeasure.update_total(num)



func _on_score_update(newScore: int) -> void:
	score = newScore
	
