extends Node2D

# How many nodes to put in the patrol
@export var path_length: int 
# The distance to try to place nodes
@export var node_distance: float
# How enemies should behave at the end of the path
@export var is_loop: bool
# How many enemies to distribute across the path
@export var enemy_count: int

@export var path_angle: float

# path_node objects
@export var path_node: PackedScene
# enemy objects attatched to this path
@export var enemy: PackedScene

@export var target: Dictionary[CharacterBody2D,bool]
var n_node
var n_enemy

var path = []

var last_pos: Vector2 = position
var angle
var node_enemies: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(path_length):
		angle = path_angle + i * PI * 2 / path_length
		last_pos = last_pos + Vector2(node_distance * cos(angle), node_distance * sin(angle))
		n_node = path_node.instantiate()
		n_node.position = last_pos
		add_child(n_node)
		path.append(n_node)
		node_enemies += float(enemy_count) / float(path_length)
		while node_enemies >= 1.0:
			node_enemies -= 1.0
			n_enemy = enemy.instantiate()
			n_enemy.position = last_pos
			n_enemy.patrol_target = i
			add_child(n_enemy)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
