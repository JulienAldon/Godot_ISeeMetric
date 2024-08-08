extends CharacterBody2D
class_name HnsCharacter

@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var movement: MovementComponent
@export var sprite: AnimatedSprite2D

var controlled_by: int

func _ready():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)
