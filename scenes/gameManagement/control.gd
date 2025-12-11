extends Control

signal menuShow
@export 
var clicked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer.hide()
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	if(Input.is_action_pressed("player_throw") and !clicked):
		clicked = true
		$VBoxContainer.show()
		$AudioStreamPlayer.play()
		menuShow.emit()
	
	pass
