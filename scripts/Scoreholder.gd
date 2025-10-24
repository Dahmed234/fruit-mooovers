extends Label


var score:int = 0
# Amount of points needed per day to not lose
var quota: int = 100

func changeScore(change :int):
	score += change
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Score: "  +  str(score)
