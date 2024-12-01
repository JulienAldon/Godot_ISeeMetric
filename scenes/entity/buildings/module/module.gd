extends TdBuilding

class_name Module

@export var sprite: AnimatedSprite2D
@export var health: HealthComponent
@export var death: DeathComponent
@export var action_controller: ActionComponent
@export var upgrade: UpgradeComponent
@export var propagation: EffectPropagationComponent

func dispawn():
	if death:
		death.death(attacker_id)

func _process(delta):
	if not is_multiplayer_authority():
		return
	super(delta)
	if health and health.health <= 0:
		dispawn()

func deactivate_behaviour():
	selection.set_target_indicator(false)
	if hitbox:
		hitbox.disabled = true
	set_process(false)
	set_physics_process(false)
	propagation.remove_local_entities_effects()
	super()
	
