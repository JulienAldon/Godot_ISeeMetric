extends CharacterBody2D
class_name RtsCharacter

@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var movement: NavigationComponent
@export var sprite: AnimatedSprite2D
@export var selection: SelectionComponent
@export var attack: AttackComponent
@export var death: DeathComponent
var attacker_id: int
var controlled_by: int
var scene: String

func _enter_tree():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)

func dispawn():
	death.death(attacker_id)

func deactivate_behaviour():
	movement.set_process(false)
	movement.set_physics_process(false)
	hitbox.disabled = true
	set_process(false)
	set_physics_process(false)

func _process(delta):
	#if is_multiplayer_authority():
	if is_multiplayer_authority():
		if health.health <= 0:
			dispawn()
