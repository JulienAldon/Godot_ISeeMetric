extends Building

class_name RtsBuilding

@export_group("Dependencies")
@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var death: DeathComponent
@export var build_phase: BuildingPhaseComponent
@export var action_controller: ActionComponent

func dispawn():
	if death:
		death.death(attacker_id)

func _enter_tree():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)

func _process(_delta):
	if not is_multiplayer_authority():
		return
	if health and health.health <= 0:
		dispawn()

func deactivate_behaviour():
	selection.set_target_indicator(false)
	if hitbox:
		hitbox.disabled = true
	set_process(false)
	set_physics_process(false)
	build_phase.set_process(false)
	action_controller.set_process(false)
	super()
