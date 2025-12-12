extends HBoxContainer

var current_cows = 0
var total_cows = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$CowLabel.text = "%d / %d" % [current_cows,total_cows]


func update_current(new_current):
	current_cows = new_current

func update_total(new_total):
	total_cows = new_total
