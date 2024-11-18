extends Entity

class_name ResourceEntity

@export var death: DeathComponent
@export var health: HealthComponent
@export var selection: SelectionSystem
@export var income: IncomeComponent
@export var hitbox: HitboxComponent

func _ready():
	is_active = false
	if not spawned_in_editor:
		visible = false

func dispawn():
	death.death(attacker_id)

func _process(_delta):
	if not is_multiplayer_authority():
		return
	if health.health <= 0:
		dispawn()

func start():
	activate_behaviour()
	is_active = true
	visible = true

func configure():
	pass

func deactivate_behaviour():
	is_active = false
	selection.set_target_indicator(false)
	income.yield_income(attacker_id)
	hitbox.disabled = true
	set_process(false)
	set_physics_process(false)

func activate_behaviour():
	death.respawn()
	selection.set_target_indicator(false)
	hitbox.disabled = false
	set_process(true)
	set_physics_process(true)
