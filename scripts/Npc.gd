extends CharacterBody2D
class_name Npc

@export var health: HealthComponent
@export var death: DeathComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var movement: Node
@export var sprite: Sprite2D
@export var attack_point: Node2D
@export var stats: Node2D
@export var minimap_icon: String

var scene: String

@export var attacker_id: int = 0
var controlled_by: int
var is_alive := true

func deactivate_behaviour():
	hitbox.disabled = true
	set_process(false)
	set_physics_process(false)
	movement.set_physics_process(false)
	movement.set_process(false)

func _ready():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)

func dispawn():
	is_alive = false
	death.death(attacker_id)

func _process(_delta):
	if is_multiplayer_authority():
		if health.health <= 0:
			dispawn()
	attack_point.look_at(get_global_mouse_position())
