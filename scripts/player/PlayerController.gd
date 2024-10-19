extends Node2D

class_name PlayerController

@export var outpost_actions: Node2D
@export var current_controller: Controller
var gui: PlayerUi
@export var camera: Camera2D
@export var ui_scene: String

@export_group("Ressources")
@export var currency: int = 0
@export var currency_type: GameManager.CurrencyType
@export var experience: float = 0
@export var level: int = 0
@export var max_level: int = 20
@export var level_threshold: int = 300
@export var level_scaling: int = 1

var spawn: Vector2
var color: Color
var player_id: int
var player_name: String

func get_outpost_actions():
	return outpost_actions

func can_spend_currency(amount):
	return amount <= currency

func spend_currency(amount):
	currency -= amount
	if currency <= 0:
		currency = 0
	gui.set_currency(currency)

@rpc("call_local", "any_peer")
func earn_currency(amount):
	currency += amount
	gui.set_currency(currency)

func set_spawn(pos):
	spawn = pos
	position = pos

func set_player_id(id: int):
	player_id = id
	name = str(id)

func set_player_ui(ui: PlayerUi):
	gui = ui

func set_player_color(_color: Color):
	color = _color
	
func set_player_name(value):
	player_name = value

func _enter_tree():
	set_multiplayer_authority(player_id)

func _ready():
	var suffix = " (client)"
	if player_id == 1:
		suffix = " (host)"
	var has_control = player_id == multiplayer.get_unique_id()
	camera.enabled = has_control
	current_controller.visible = has_control
	if !has_control:
		current_controller.process_mode = PROCESS_MODE_DISABLED
	gui.show_player_ui(has_control)
	gui.visible = has_control
	gui.set_player_name(str(player_name) + suffix)
	gui.set_currency(currency)

@rpc("any_peer", "call_local")
func set_experience(value):
	experience += value
	on_experience_changed()

func show_entities_informations(entities, _id):
	gui.show_informations(entities)

func get_displayed_action():
	return gui.get_actions_from_source()

func show_entities_actions(entities, id):
	if entities.size() <= 0:
		return
	if id == entities[0].controlled_by:
		gui.show_actions(entities)
	
func show_entity_informations(entity, _id):
	gui.show_informations([entity])

func show_entity_actions(entity, id):
	if id == entity.controlled_by:
		gui.show_actions([entity])

func hide_entity_informations(_id):
	var source = gui.get_informations_source()
	if source.size() <= 0:
		return
	gui.hide_informations()

func hide_entity_actions(_id):
	var source = gui.get_actions_source()
	if source.size() <= 0:
		return
	gui.hide_actions()

func on_experience_changed():
	if is_multiplayer_authority():
		var current_level = floor(int(experience / level_threshold))
		level = current_level
		gui.set_player_level(level)
