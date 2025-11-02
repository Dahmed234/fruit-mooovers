extends CanvasLayer
@onready var root: Node2D = $".."
@onready var settings: Control = $Control/Settings

func _ready() -> void:
	settings.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if root.isPaused:
		settings.show()
		settings.position = Vector2(1920,1080) / 2
	else:
		settings.hide()
