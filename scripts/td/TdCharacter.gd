extends Entity

class_name TdCharacter

@export var animation: AnimationComponent
@export var sprite: AnimatedSprite2D
@export var stats: CharacterStats
@export var movement: MovementComponent
@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var selection: SelectionComponent
@export var action_controller: ActionComponent
@export var build: BuildComponent

func hide_actions_to(_player):
	pass
	#if player != multiplayer.get_unique_id():
		#GameManager.get_player(player).hide_entity_actions(self, player)
