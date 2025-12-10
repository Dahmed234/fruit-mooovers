class_name ProjectileResource
extends Resource

enum ProjType {
	REGULAR,
	MISSILE,
	EXPLOSION,
	BEAM,
}

## Damage dealt to target
@export var damage: float
## Damage dealt to target
@export var speed: float
## Sprite to render NOTE projectile sprites should be 64x64 or the hitbox will be the wrong size
@export var sprite: Texture2D
## Radius of collision box
@export var size: float
## How aggressivelty the projectile homes (in degree radians / second)
@export var homing_factor: float
## How hany seconds until the projectile expires
@export var life_time: float

@export var projectile_type: ProjType

@export var expiration_attack: AttackPattern

@export var pierce: int

@export var particle_type: PackedScene
