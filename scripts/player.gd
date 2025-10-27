extends CharacterBody2D



var enemy_weight := 0.2

@export var speed: float
# The distance that a cow can be thrown from the player
@export var throwDistance: float
# The cows currently in the throwing radius, i.e. that can be thrown by clicking
@onready var throwRadius: Area2D = $"Radii/Throw Radius"

func getThrowPosition():
	return global_position.direction_to(get_global_mouse_position()) * min(global_position.distance_to(get_global_mouse_position()),throwDistance)

var direction: Vector2

func move(delta: float) -> void:
	direction = Vector2.ZERO
	# Apply left / right movement
	direction.x = Input.get_axis("player_move_left", "player_move_right");
	direction.y = Input.get_axis("player_move_up", "player_move_down");
	
	#added normalisation to fix buf that happens when player inputs diagonal to move faster
	direction = direction.normalized();
		
	# Apply up / down movement
	velocity = direction * speed * delta


func _physics_process(delta: float) -> void:
	move(delta)
	
	move_and_slide()
