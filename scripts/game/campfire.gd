extends StaticBody2D

@export var npc_scene: String
@export var spawn_timer: Timer
@export var capture_timer: Timer
@export var reset_timer: Timer
@export var sprite: AnimatedSprite2D
@export var effect_area: CollisionShape2D
@export var max_capture_stage: int = 5

@export var controlled_by := 0
var can_spawn: bool = true
var is_capturing: bool = false
var is_reseting: bool = false
@export var capture_stage: int = 0
var capturing_player: int = 0
var players: Array = []

signal property_change

func _ready():
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	capture_timer.timeout.connect(on_capture_timer_timeout)
	reset_timer.timeout.connect(on_reset_timer_timeout)
	var player_color = Color.GRAY
	if controlled_by != 0:
		player_color = GameManager.Players[controlled_by]["color"]
	sprite.modulate = player_color

func spawn_npc():
	if can_spawn:
		var loc_pos = effect_area.global_position
		var location_shape = effect_area.shape.radius
		var pos = Vector2(
			randf_range(loc_pos.x - location_shape, loc_pos.x + location_shape), 
			randf_range(loc_pos.y - location_shape, loc_pos.y + location_shape)
		)
		var informations = {
			"controlled_by": 1,
			"position": pos,
		}
		can_spawn = false
		spawn_timer.start()
		GameManager.spawn_entity.call_deferred(npc_scene, informations)
		
func _process(delta):
	
	if controlled_by == 0:
		sprite.modulate = Color.GRAY
	else:
		sprite.modulate = GameManager.Players[controlled_by]["color"]
	if not is_multiplayer_authority():
		$CapturingProgress.update()
		return
	if controlled_by == 0:
		spawn_npc()
		sprite.modulate = Color.GRAY
	else:
		sprite.modulate = GameManager.Players[controlled_by]["color"]

func start_reset(player_id):
	capturing_player = player_id
	is_reseting = true
	reset_timer.start()

func stop_reset():
	reset_timer.stop()
	is_reseting = false
	capturing_player = 0

func stop_capture():
	is_capturing = false
	capturing_player = 0
	capture_timer.stop()

func start_capture(player_id):
	is_capturing = true
	capturing_player = player_id
	capture_timer.start()

func on_spawn_timer_timeout():
	can_spawn = true
	spawn_timer.stop()

func on_capture_timer_timeout():
	capture_stage += 1
	property_change.emit()
	if capture_stage >= max_capture_stage:
		print(controlled_by)
		controlled_by = capturing_player
		stop_capture()
		capture_stage = max_capture_stage
	else:
		capture_timer.start()

func on_reset_timer_timeout():
	capture_stage -= 1
	property_change.emit()
	if capture_stage <= 0:
		capture_stage = 0
		controlled_by = 0
		stop_reset()
		if players.size() > 0:
			start_capture(players[0].controlled_by)
	else:
		reset_timer.start()

func _on_effect_radius_body_entered(body):
	if not is_multiplayer_authority():
		return
	if !body.is_in_group("player_entity"):
		return
	players.append(body)
	if capturing_player == 0:
		print("enter ", body.controlled_by)
		start_capture(body.controlled_by)
	else:
		is_capturing = false

func _on_effect_radius_body_exited(body):
	if not is_multiplayer_authority():
		return
	if !body.is_in_group("player_entity"):
		return
	players.erase(body)
	if capturing_player == body.controlled_by:
		print("exit ", body.controlled_by)
		stop_capture()

	if players.size() > 0:
		start_reset(players[0].controlled_by)

func _input_event(viewport, event, shape_idx):
	if controlled_by == 0: 
		return
	if multiplayer.get_unique_id() != controlled_by:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GameManager.get_player(controlled_by).open_hub_inventory()
