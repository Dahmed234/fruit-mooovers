class_name AttackPattern
extends Resource


## The path the enemy moves while attacking, relative to the target
@export var movement: Curve2D
## The length in seconds of the attack
@export var attack_time: float
## The projectile to be created by the enemy
@export var projectile_type: ProjectileResource
## How many projectiles the enemy should use
@export var projectile_count: int
## How spread projectiles should be
@export var projectile_spread: int
