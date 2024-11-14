extends Node2D

class_name PlayerController

@export var outpost_actions: Node2D
@export var current_controller: Controller
var gui: PlayerUi
@export var camera: Camera2D
@export var ui_scene: String

@export_group("Ressources")
var currencies: Dictionary = {}
@export var currency: int = 0
@export var experience: float = 0
@export var level: int = 0
@export var max_level: int = 20
@export var level_threshold: int = 300
@export var level_scaling: int = 1

var spawn: Vector2
var color: Color
var player_id: int
var player_name: String
var last_target: Entity
var last_select: Entity

var outposts: Array[Node]

func get_owned_outpost() -> Array[Node]:
	return outposts.filter(func(el): return is_instance_valid(el) and el.controlled_by == player_id)

func can_queue_action(action: Action) -> bool:
	return can_spend_currency(action.cost) and current_controller.can_queue_action(action)

func get_player_offset() -> Vector2:
	return current_controller.get_player_offset()

func interact_entity(entity: Entity):
	if last_target and is_instance_valid(last_target):
		last_target.selection.set_target_indicator(false)
	last_target = entity
	if entity.controlled_by != player_id:
		entity.selection.set_target_indicator(true)
	current_controller.interact_entity(entity)

func mass_select_entity(entities: Array):
	current_controller.mass_select_entity(entities)

func select_entity(entity: Entity):
	last_select = entity
	current_controller.select_entity(entity)
	show_entity_informations(entity, multiplayer.get_unique_id())

func stop_interact_entity(entity: Entity):
	current_controller.stop_interact_entity(entity)

func reset_state():
	if is_instance_valid(last_target):
		last_target.selection.set_target_indicator(false)
	if is_instance_valid(last_select):
		hide_entity_informations(player_id)

func get_outpost_actions():
	return outpost_actions

func can_spend_currency(costs: Array[ResourceYield]) -> bool:
	for resource_yield in costs:
		if not currencies.has(resource_yield.type):
			return false
		if resource_yield.value > currencies[resource_yield.type]:
			return false
	return true

func spend_currency(costs: Array[ResourceYield]):
	for resource_yield in costs:
		if not currencies.has(resource_yield.type):
			return
		currencies[resource_yield.type] -= resource_yield.value
	gui.set_currency(currencies)

@rpc("call_local", "any_peer")
func earn_currency(value: int, type: GameManager.CurrencyType):
	if currencies.has(type):
		currencies[type] += value
	else:
		currencies[type] = value
	gui.set_currency(currencies)

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
	gui.set_currency(currencies)
	outposts = GameManager.get_level_outposts()

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
