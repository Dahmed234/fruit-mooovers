extends Label

var opacity := 1.0
var lifespan := 5.0
var time := 0.0
var speed: float
var delay := 0.0
var startPos := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = randf_range(-0.5,0.5)
	speed = randf_range(0.8,1.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if startPos == Vector2.ZERO: startPos = position
	# Allow a delay before showing text
	if delay > 0:
		hide()
		delay -= delta * speed
		if delay <= 0: show() 
		else: return
	# Slowly move the text and fade it out
	opacity = 1.0 - (time / lifespan)
	modulate.a = opacity
	time += delta * speed
	position.y = startPos.y + opacity * 50.0
	if time >= lifespan:
		queue_free()
