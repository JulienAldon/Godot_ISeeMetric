extends Node2D

#@export var death_behaviours: Array
class_name DeathComponent

@export_group("Dependencies")
@export var sprite: Node2D
@export var health: HealthComponent
@export var body: Entity

@export_category("Configuration")
@export var experience_yield: int = 20
@export var free_on_death: bool = true

@export_group("Intern")
@export var corpse: Sprite2D
@export var delete_timer: Timer
@export var corpse_time: int = 30

var is_dead: bool = false

func _ready():
	if delete_timer:
		delete_timer.timeout.connect(_on_timer_timeout)
		delete_timer.wait_time = corpse_time

func respawn():
	corpse.hide()
	is_dead = false
	health.heal(health.max_health)
	sprite.show()
	health.show()

@rpc("any_peer", "call_local")
func show_corpse():
	corpse.show()
	is_dead = true
	sprite.hide()
	health.hide()
	body.deactivate_behaviour()

func yield_experience(attacker_id):
	GameManager.set_player_experience(attacker_id, experience_yield)

func death(attacker_id):
	# TODO: skill on death behaviour
	yield_experience(attacker_id)
	#play_death_animation
	show_corpse.rpc()
	delete_timer.start()
	GameManager.set_player_experience(attacker_id, 10)

@rpc("any_peer", "call_local")
func delete_corpse():
	if is_multiplayer_authority():
		body.call_deferred("queue_free")
	 
func _on_timer_timeout():
	if free_on_death:
		delete_corpse.rpc()
	else:
		body.hide()
