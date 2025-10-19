extends CharacterBody2D

# --- ENUMS ---
enum PikminState { IDLE, FOLLOWING, WANDERING, ATTACKING }

# --- EXPORTED VARIABLES ---
@export var speed: float = 100.0
@export var light_level: float = 1.0
@export var target: CharacterBody2D
@export var is_chasing: bool = true

# --- NODES ---
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback = animation_tree.get("parameters/playback")
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# --- STATE VARIABLES ---
var state: PikminState = PikminState.WANDERING
var direction: Vector2 = Vector2.ZERO
var try_attack: bool = false
var next_path_position: Vector2 = Vector2.INF

# --- WANDER SETTINGS ---
@export var min_wander_distance: float = 50.0
@export var max_wander_distance: float = 100.0
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 5.0
var wait_time: float = 0.0
var stuck_time: float = 0.0
var max_stuck_time: float = 2.0

# --- LIFECYCLE ---

func _ready() -> void:
	update_target(generate_random_target())

func _process(_delta: float) -> void:
	#update_state()
	update_animation()

func _physics_process(delta: float) -> void:
	handle_navigation(delta)
	move_and_slide()
	handle_collision(get_last_slide_collision(), delta)
	print((target.position - global_position).length() > navigation_agent.target_desired_distance)

# --- STATE MANAGEMENT ---

func set_state(new_state: PikminState) -> void:
	state = new_state

# --- ANIMATION ---

func update_animation() -> void:
	animation_tree.set("parameters/conditions/Idle", direction.length() <= 0 && state != PikminState.ATTACKING)
	animation_tree.set("parameters/conditions/Run", direction.length() > 0 && state != PikminState.ATTACKING)
	animation_tree.set("parameters/conditions/Attack", state == PikminState.ATTACKING)
	
	# Always update blend positions
	for anim in ["Idle", "Walk", "Attack"]:
		animation_tree.set("parameters/%s/blend_position" % anim, direction)

# --- MOVEMENT & NAVIGATION ---

func handle_navigation(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		match state:
			PikminState.WANDERING:
				_on_target_reached_wandering()
			PikminState.FOLLOWING:
				state = PikminState.IDLE
				
	match state:
		PikminState.IDLE:
			direction = Vector2.ZERO
			if (target.position - global_position).length() > navigation_agent.target_desired_distance:
				state = PikminState.FOLLOWING
				update_target(target.position)
		PikminState.FOLLOWING:
			_navigate_following()
		PikminState.WANDERING:
			_navigate_wandering(delta)
		PikminState.ATTACKING:
			velocity = Vector2.ZERO

func move_to_target() -> void:
	next_path_position = navigation_agent.get_next_path_position()

	direction = global_position.direction_to(next_path_position)
	var desired_velocity = speed * direction

	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(desired_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(desired_velocity)

func _on_target_reached_wandering():
	wait_time = randf_range(min_wait_time, max_wait_time)
	update_target(generate_random_target())
	direction = Vector2.ZERO
	
func _navigate_wandering(delta: float):
	if wait_time > 0:
		wait_time -= delta
		stuck_time = max_stuck_time
	else:
		if stuck_time <= 0:
			update_target(generate_random_target())
			stuck_time = max_stuck_time
			
		move_to_target()
	
func _navigate_following():
	update_target(target.position)
	move_to_target()
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func handle_collision(collision: KinematicCollision2D, delta: float) -> void:
	if collision:
		var desired_dir = global_position.direction_to(next_path_position)
		var collision_dir = global_position.direction_to(collision.get_position())
		velocity = collision_dir.reflect(desired_dir) * speed;
		move_and_slide()
		stuck_time -= delta;
	else:
		stuck_time = max_stuck_time;

# --- TARGETING & RANDOMIZATION ---

func update_target(new_target: Vector2) -> void:
	navigation_agent.target_position = new_target

func generate_random_target() -> Vector2:
	var rand_x = randf_range(min_wander_distance, max_wander_distance) * (1 if randf() > 0.5 else -1)
	var rand_y = randf_range(min_wander_distance, max_wander_distance) * (1 if randf() > 0.5 else -1)
	return global_position + Vector2(rand_x, rand_y)
