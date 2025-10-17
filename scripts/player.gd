extends CharacterBody2D


@export var speed: float
func move(delta: float) -> void:
	var direction: float
	# Apply left / right movement
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed 
	# Move towards 0 velocity with no input
	else:
		velocity.x = move_toward(velocity.x, 0, speed )
		
	# Apply up / down movement
	direction = Input.get_axis("ui_up", "ui_down")
	if direction:
		velocity.y = direction * speed
	# Move towards 0 velocity with no input
	else:
		velocity.y = move_toward(velocity.x, 0, speed)


func _physics_process(delta: float) -> void:
	move(delta)

	move_and_slide()
