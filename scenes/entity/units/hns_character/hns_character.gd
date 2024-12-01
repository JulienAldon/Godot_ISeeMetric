extends Entity
class_name HnsCharacter

@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var movement: MovementComponent
@export var sprite: AnimatedSprite2D
@export var attack_point: Node2D
@export var weapon: Sprite2D
@export var skills: Node2D
@export var selection: SelectionComponent
@export var animation: AnimationController

func _ready():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)

func _process(_delta):
	#if health.health <= 0:
		#queue_free()
	weapon.frame = stats.get_weapon().style
	attack_point.look_at(get_global_mouse_position())
