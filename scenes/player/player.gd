extends CharacterBody2D

signal playerDies


const detection_weight := 5

@export var speed: float
# The distance that a cow can be thrown from the player
@export var throwDistance: float
# The cows currently in the throwing radius, i.e. that can be thrown by clicking
@onready var throwRadius: Area2D = $"Radii/Throw Radius"

var chasing: Dictionary[CharacterBody2D,bool] = {}
@onready var health_bar: TextureProgressBar = $Sprite2D/Health

@export var health : float
var max_health
@onready var bar: TextureProgressBar = $Sprite2D/Health

var is_moving = true

func _ready():
	max_health = health
	health_bar.max_value = max_health

func damage(enemy_damage):
	pass
	#health -= enemy_damage

func die() -> void:
	# remove this follower from list of enemies chasing it
	for cone_light in chasing:
		if !chasing[cone_light]: continue
		cone_light.clear_target(self)
	
	print("player die!!!!")
	
	playerDies.emit()

func getThrowPosition():
	return global_position.direction_to(get_global_mouse_position()) * min(global_position.distance_to(get_global_mouse_position()),throwDistance)

var direction: Vector2

func move(_delta: float) -> void:
	direction = Vector2.ZERO
	# Apply left / right movement
	direction.x = Input.get_axis("player_move_left", "player_move_right");
	direction.y = Input.get_axis("player_move_up", "player_move_down");

	if(direction ==Vector2.ZERO):
		$AnimationTree.is_moving = false
	else:
		$AnimationTree.is_moving = true
	#added normalisation to fix buf that happens when player inputs diagonal to move faster
	direction = direction.normalized();
	
	# Apply up / down movement
	velocity = direction * speed 


func _physics_process(delta: float) -> void:
	health_bar.value = health
	
	
	if health <= 0: die()
	move(delta)
	
	move_and_slide()
	
func _process(delta: float) -> void:
	$AudioStreamPlayer.play_footstep = velocity.length() != 0
