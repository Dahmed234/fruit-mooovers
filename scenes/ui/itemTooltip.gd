extends PanelContainer



var currentItem :Carryable = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_modulate(Color(1,1,1,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var overlappingCarryables = get_tree().get_nodes_in_group("Carryable").filter(func( x):return x.bounds.has_point(x.get_local_mouse_position()))
	
	currentItem = overlappingCarryables.pop_back()
	
	if currentItem == null:
		set_modulate(lerp(get_modulate(), Color(1,1,1,0), 0.2))
		return
	
	set_modulate(lerp(get_modulate(), Color(1,1,1,1), 0.2))
	show()
	$HBoxContainer/coinIcon.visible = currentItem.value > 0
	$HBoxContainer/coinAmountLabel.visible = currentItem.value > 0
	$HBoxContainer/coinAmountLabel.text = str(currentItem.value )
	
	$HBoxContainer/fruitName.text = currentItem.fruitName
	$HBoxContainer/cowAmountLabel.visible = currentItem.followerValue > 0
	$HBoxContainer/cowIcon.visible = currentItem.followerValue > 0
	$HBoxContainer/cowAmountLabel.text = str(currentItem.followerValue)
	
	
	
	
	pass
