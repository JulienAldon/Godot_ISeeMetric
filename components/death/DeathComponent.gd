extends Node2D

#@export var death_behaviours: Array
class_name DeathComponent

@export var experience_yield: int = 20
@export var corpse: Sprite2D
@export var body: CharacterBody2D
@export var delete_timer: Timer
@export var corpse_time: int = 30

func _ready():
	delete_timer.wait_time = corpse_time
	
@rpc("any_peer", "call_local")
func show_corpse():
	corpse.show()
	corpse.flip_h = body.sprite.flip_h
	body.sprite.hide()
	body.health.hide()
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
	body.queue_free()
	 
func _on_timer_timeout():
	delete_corpse.rpc()
	#call_deferred("queue_free")
