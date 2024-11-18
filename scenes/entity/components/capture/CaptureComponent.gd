extends Node2D

class_name CaptureComponent

signal property_change

@export_group("Dependencies")
@export var income: IncomeComponent
@export var build: BuildComponent
@export var body: Entity

@export_category("Configuration")
@export var max_capture_stage: int = 10

@export_category("Multiplayer replication")
@export var capture_stage: float = 0
@export var capturing_player: int = 0
@export var is_reset: bool = false
@export var previous_owner: int = 0

@export_group("Intern")
@export var capturing_progress: Control
@export var capture_delimiter: ColorRect
@export var capture_progress: CustomProgresBar

var players: Array = []
var capture_started: bool = false
var reset_started: bool = false
var player_starting_capture: int
var has_progress: bool = false

func get_controlled_by():
	return body.controlled_by

func _process(delta):
	var color = GameManager.get_player_color(body.controlled_by)
	var alpha = 0.2
	if not is_reset and capturing_player != 0:
		color = GameManager.get_player_color(capturing_player)
	elif is_reset:
		color = GameManager.get_player_color(previous_owner)
	else:
		color = GameManager.get_player_color(body.controlled_by)
	capture_progress.tint_progress = color
	color = GameManager.get_player_color(capturing_player)
	if capturing_player != 0:
		alpha = 0.8
	capture_delimiter.material.set_shader_parameter("color", Color(color.r, color.g, color.b, alpha))
	capture_progress.update()
	if not is_multiplayer_authority():
		return
	has_progress = capture_stage != 0 and capture_stage != max_capture_stage
	if capture_condition() and players.size() > 0:
		capturing_player = players[0].controlled_by
		if body.controlled_by == 0 or (has_progress and capturing_player == body.controlled_by):
			capture_started = true
			is_reset = false
		elif players[0].controlled_by != body.controlled_by:
			is_reset = true
			reset_started = true
	else:
		capturing_player = 0
		capture_started = false
		reset_started = false
		is_reset = false
	
	if capture_started:
		capture_stage += delta
		property_change.emit()
		if capture_stage >= max_capture_stage:
			capture_success()
	if reset_started:
		capture_stage -= delta
		property_change.emit()
		previous_owner = body.controlled_by
		if capture_stage <= 0:
			capture_reset()

func capture_success(controlled: int = 0):
	capture_stage = max_capture_stage
	capture_started = false
	if controlled != 0:
		body.controlled_by = controlled
		income.start_currency_yield()
	elif players.size() > 0:
		body.controlled_by = players[0].controlled_by
		income.start_currency_yield()

func capture_reset():
	capture_stage = 0
	reset_started = false
	previous_owner = body.controlled_by
	body.controlled_by = 0
	income.stop_currency_yield()
	build.destroy_buildings.rpc(capturing_player)

func capture_condition():
	if players.size() <= 0:
		return false
	var tmp: int = players[0].controlled_by
	for entity in players:
		if not is_instance_valid(entity):
			players.erase(entity)
			continue
		if entity.controlled_by != tmp:
			return false
	return true

func _on_capture_radius_body_entered(_body):
	if not is_multiplayer_authority():
		return
	if !_body.is_in_group("player_entity"):
		return
	players.append(_body)


func _on_capture_radius_body_exited(_body):
	if not is_multiplayer_authority():
		return
	if !_body.is_in_group("player_entity"):
		return
	players.erase(_body)
