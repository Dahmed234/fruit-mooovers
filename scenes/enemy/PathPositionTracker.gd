extends PathFollow2D


var movement_direction = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent :=  (get_parent() as Path2D).curve
	var startPoint = parent.get_point_position(0)
	var endPoint = parent.get_point_position(parent.point_count -1)
	

	if (parent.point_count >=  2 && startPoint == endPoint):
		loop = true
	else: 
		loop = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func advance(distance):
	progress += movement_direction * distance

	if(loop): return
	
	if(progress_ratio >= 0.95):
		movement_direction = -1
	if(progress_ratio <= 0.05):
		movement_direction = 1
