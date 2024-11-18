extends Controller
class_name RtsController

@export var camera_margin := 30
@export var camera_speed := 800
@export var cursor_animation_scene: String
@export var select_controller: SelectController

func minimap_command_action(pos: Vector2):
	command_or_append_unit_action(pos, null)

func minimap_command_position(pos: Vector2):
	player.position = pos

func _ready():
	center_offset = (Vector2(get_viewport_rect().size)) / 2
	color = player.color
	player.position -= center_offset
	super()
	
func camera_control(delta):
	var input_axis:= Vector2(0,0)
	input_axis.x = Input.get_axis("Left", "Right")
	input_axis.y = Input.get_axis("Top", "Bottom")
	var local_mouse_pos = get_viewport().get_mouse_position()
	var threshold = camera_margin
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_movement := Vector2(0,0)
	if local_mouse_pos.x <= threshold and local_mouse_pos.x > -threshold:
		camera_movement.x = -1
	if (local_mouse_pos.x >= (viewport_size.x / camera.get_zoom().x) - threshold):
		camera_movement.x = 1
	if local_mouse_pos.y <= threshold and local_mouse_pos.y > -threshold:
		camera_movement.y = -1
	if (local_mouse_pos.y >= (viewport_size.y/ camera.get_zoom().y) - threshold):
		camera_movement.y = 1
	if not mouse_in_window:
		camera_movement = Vector2(0, 0)
	var movement = camera_movement * camera_speed if camera_movement != Vector2(0, 0) else input_axis * camera_speed
	if movement != Vector2(0, 0):
		queue_redraw()
	player.position += movement * camera.get_zoom() * delta

func interact_entity(entity):
	if entity.controlled_by == player_id:
		return
	var mouse_pos = get_global_mouse_position()
	if select_controller.get_selected().size() > 0:
		command_or_append_unit_action(mouse_pos, entity)
		select_controller.queue_redraw()

func stop_interact_entity(_entity):
	if select_controller.dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		select_controller.set_stop_dragging(
			_entity.position, 
			get_world_2d().direct_space_state, 
			func(el): return el.collider.controlled_by == player_id
		)
		select_controller.queue_redraw()

func select_entity(entity: Entity):
	select_controller.reset_selection()
	if entity.is_in_group("rts_unit"):
		select_controller.set_selected([entity])

func mass_select_entity(entities: Array):
	select_controller.reset_selection()
	if not false in entities.map(func(el): return el.is_in_group("rts_unit")):
		select_controller.set_selected(entities)

func command_or_append_unit_action(mouse_pos: Vector2, entity):
	show_cursor_anim(mouse_pos)
	var target: Entity
	if entity and entity.controlled_by != multiplayer.get_unique_id():
		target = entity
	else:
		target = null
	select_controller.sanitize_selected()
	var group_map = select_controller.create_selected_map()
	if Input.is_key_pressed(KEY_SHIFT):
		move_controller.append_movement(mouse_pos, group_map)
	else:
		var attack_move = false
		if Input.is_key_pressed(KEY_CTRL):
			attack_move = true
		move_controller.command_movement(mouse_pos, target, attack_move or target, group_map)

func show_cursor_anim(pos: Vector2):
	var anim = load(cursor_animation_scene).instantiate()
	anim.global_position = pos
	GameManager.get_level_tilemap().add_child(anim)

func filter_allies(e):
	return e.controlled_by != player_id
	
@export var char_scene: String = ""
@export var char_scene_2: String = ""
@export var char_scene_3: String = ""

func can_queue_action(_action: Action):
	var can_queue: bool = true
	return can_queue

func _unhandled_input(event):
	select_controller.selection_control(event)
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.is_pressed():
			player.reset_state()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and select_controller.get_selected().size() > 0:
				command_or_append_unit_action(mouse_pos, null)
				select_controller.queue_redraw()
			
	if Input.is_action_pressed("action_slot_4"):
		GameManager.spawn_character(char_scene, {"position": mouse_pos, "controlled_by": player_id})
	if Input.is_action_pressed("action_slot_3"):
		GameManager.spawn_character(char_scene_2, {"position": mouse_pos, "controlled_by": player_id})
	if Input.is_action_pressed("action_slot_2"):
		GameManager.spawn_character(char_scene_3, {"position": mouse_pos, "controlled_by": player_id})	
	

func _physics_process(delta):
	camera_control(delta)
	select_controller.queue_redraw()

func _process(_delta):
	queue_redraw()

var mouse_in_window = true

func _notification(notif):
	match notif:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true
