extends Entity

class_name TdCharacter

@export var network: NetworkComponent
@export var animation: AnimationController
@export var sprite: AnimatedSprite2D
@export var stats: CharacterStats
@export var movement: MovementComponent
@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var selection: SelectionSystem
@export var action_controller: ActionHandler
@export var build: BuildComponent
@export var attack: CollectComponent

func _ready():
	if network:
		network.set_authority(controlled_by)
