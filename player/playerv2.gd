extends CharacterBody2D

#todo: buffer attacks
enum PlayerState
{
	Idle,
	Walking,
	Attacking
}

@export var speed: float
@export var light_level: float 
@onready var animation_tree = $AnimationTree;
@onready var animation_tree_playback = $AnimationTree.get("parameters/playback");

@export var pikmin_scene: PackedScene
@export var throw_offset: float = 200.0

var direction: Vector2 = Vector2(0, 0);
var state: PlayerState = PlayerState.Idle;
var is_sneaking: bool = false;

#Update Finite State Machine Based on User Input
func consumeInput() -> void:
	direction.x = Input.get_axis("player_move_left", "player_move_right");
	direction.y = Input.get_axis("player_move_up", "player_move_down");
	
	#added normalisation to fix buf that happens when player inputs diagonal to move faster
	direction = direction.normalized();
	
	if (Input.is_action_just_pressed("player_toggle_sneak")):
		is_sneaking = !is_sneaking;
	
	#Pattern match to correct state
	if direction.length() <= 0:
		state = PlayerState.Idle 
	else:
		state = PlayerState.Walking
		
	if (Input.is_action_just_pressed("player_throw")):
		_throw_pikmin()
		

#update speed and light based on state
func update() -> void:
	if (animation_tree_playback.get_current_node() == "Attack"):
		state = PlayerState.Attacking
		
	match [state, is_sneaking]:
		[PlayerState.Idle, false], [PlayerState.Walking, false]:
			light_level = 400;
			speed = 50;
		[PlayerState.Idle, true], [PlayerState.Walking, true]:
			light_level = 300;
			speed = 2000;
		[PlayerState.Attacking, false]:
			light_level = 700;
			speed = 2000;
		[PlayerState.Attacking, true]:
			light_level = 350;
			speed = 2000;
			
func animate() -> void:
	animation_tree.set("parameters/conditions/Idle", state == PlayerState.Idle);
	animation_tree.set("parameters/conditions/Run", state == PlayerState.Walking);
	animation_tree.set("parameters/conditions/Attack", state == PlayerState.Attacking);
	
	if state == PlayerState.Walking:
		animation_tree.set("parameters/Idle/blend_position", direction);
		animation_tree.set("parameters/Walk/blend_position", direction);
		animation_tree.set("parameters/Attack/blend_position", direction);
		
func _process(_delta: float) -> void:
	consumeInput()
	update()
	animate()

#movement in physics tick
func _physics_process(delta: float) -> void:
	
	if state == PlayerState.Attacking:
		velocity = Vector2(0, 0);
	else:
		velocity = direction * speed;#is multiplication by delta redundant?
	move_and_slide()
	
func _throw_pikmin():
	if pikmin_scene == null:
		push_error("Pikmin scene not assigned!")
		return
	
	# Spawn pikmin at offset from player's facing direction
	var spawn_position = global_position + (direction * throw_offset)
	
	# Instantiate the pikmin
	var pikmin_instance = pikmin_scene.instantiate()
	pikmin_instance.target = self
	get_parent().add_child(pikmin_instance)
	pikmin_instance.global_position = spawn_position
