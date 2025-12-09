extends Node

const SETTINGS = preload("uid://iirnlrmeohsh")
var settings_layer: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var settings = SETTINGS.instantiate()
	# Add a canvas layer to be the settings menu's parent to render it above everything else.
	settings_layer = CanvasLayer.new()
	settings_layer.layer = 2
	settings_layer.add_child(settings)
	get_tree().root.add_child.call_deferred(settings_layer)
	settings_layer.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		# Toggle pause
		if get_tree().paused:
			settings_layer.hide()
		else:
			settings_layer.show()
		get_tree().paused = !get_tree().paused
		
