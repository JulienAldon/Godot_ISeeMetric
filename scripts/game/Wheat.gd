extends Entity

class_name Wheat

@export var death: DeathComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var health: HealthComponent
@export var selection: SelectionComponent
@export var income: IncomeComponent

func dispawn():
	hitbox.disabled = true
	GameManager.get_level_tilemap().bake_navigation()
	death.death(attacker_id)
	
func deactivate_behaviour():
	selection.set_target_indicator(false)
	hitbox.disabled = true
	income.yield_income(attacker_id)
	set_process(false)
	set_physics_process(false)

func _process(_delta):
	if not is_multiplayer_authority():
		return
	if health.health <= 0:
		dispawn()
