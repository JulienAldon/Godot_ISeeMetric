extends CharacterBody2D
class_name RtsCharacter

@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var movement: NavigationComponent
@export var sprite: AnimatedSprite2D
@export var selection: SelectionComponent
@export var attack: AttackComponent
var controlled_by: int

func _enter_tree():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)
