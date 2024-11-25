extends TdBuilding

class_name Turret

@export var health: HealthComponent
@export var death: DeathComponent
@export var stats: EntityStats
@export var sprite: AnimatedSprite2D
@export var attack: AttackComponent
@export var action_controller: ActionComponent
@export var upgrade: UpgradeComponent

func dispawn():
	if death:
		death.death(attacker_id)

func _process(delta):
	if not is_multiplayer_authority():
		return
	super(delta)
	if health and health.health <= 0:
		dispawn()
	if attack.has_target():
		attack.set_target(attack.get_target())
		if attack.is_attack_possible():
			attack.attack_target()

func deactivate_behaviour():
	selection.set_target_indicator(false)
	if hitbox:
		hitbox.disabled = true
	set_process(false)
	set_physics_process(false)
	attack.hide()
	attack.set_process(false)
	attack.set_physics_process(false)
	super()
