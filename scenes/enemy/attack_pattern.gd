extends Node

class_name AttackPattern

## The path the enemy moves while attacking, relative to the target
var movement: Curve2D
## The length in seconds of the attack
var attack_time: float
## The projectile to be created by the enemy
var projectile_type: PackedScene
## How many projectiles the enemy should use
var projectile_count: int
