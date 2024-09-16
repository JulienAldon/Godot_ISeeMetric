extends Controller
class_name RtsController

@export var camera_margin := 50
@export var camera_speed := 800
@export var units: Node
var camera_movement := Vector2(0,0)

var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()
var selected = []
var dragging = false
var tilemap: TileMap

func _ready():
	tilemap = GameManager.get_level_tilemap()
	color = player.color
	player_id = player.name.to_int()
	var has_control = player_id == multiplayer.get_unique_id()
	player.gui.show_player_ui(has_control)
	player.gui.visible = has_control
	camera.enabled = has_control
	self.visible = has_control
	if !has_control:
		process_mode = PROCESS_MODE_DISABLED

func set_start_dragging(pos):
	dragging = true
	drag_start = pos

func set_stop_dragging(stop, space, filter_func):
	dragging = false
	selected = compute_selected_units(drag_start, stop, space, filter_func)
	set_selected_units(true)

func set_selected_units(status):
	for unit in selected:
		if is_instance_valid(unit.collider) and unit.collider.is_in_group("rts_unit"):
			unit.collider.selection.set_selected(status)

func set_selected(value):
	selected = value

func find_nearest(points: Dictionary, pos: Vector2, distance: int):
	for point in points:
		var point_distance = point.distance_to(pos)
		if point_distance <= distance:
			return point 
	return false

func reset_selection():
	set_selected_units(false)
	set_selected([])

func get_nearest_target(pos):
	var target_entity = compute_selected_units(
		Vector2(pos.x + 10, pos.y + 10),
		Vector2(pos.x - 10, pos.y - 10),
		get_world_2d().direct_space_state,
		func(el): return str(el.collider.controlled_by).to_int() != player_id
	)
	return target_entity

func calculate_mean_position(group):
	var mean_pos := Vector2(0, 0)
	
	for unit in group:
		mean_pos += unit.position
	mean_pos /= group.size()
	return mean_pos

func remove_duplicates(items: Array) -> Array:
	var unique = []
	for item in items:
		if not unique.has(item):
			unique.append(item)
	return unique

func create_group_map(group):
	var group_map = {}
	
	for unit in group:
		group_map[unit.get_instance_id()] = unit
	
	return group_map
	
func command_unit_action(click_position):
	var group = selected.map(func(el): return el.collider)
	var pos = calculate_mean_position(group)
	var	path = remove_duplicates(tilemap.get_navigation_path(pos, click_position))
	var group_map = create_group_map(group)
	for unit in group:
		if is_instance_valid(unit) and unit.is_in_group("rts_unit"):
			unit.movement.command_navigation(click_position, group_map, path)

func append_unit_action(click_position):
	var group = selected.map(func(el): return el.collider)
	var pos = group[0].movement.target_position
	var	path = remove_duplicates(tilemap.get_navigation_path(pos, click_position))
	var group_map = create_group_map(group)
	for unit in group:
		if is_instance_valid(unit) and unit.is_in_group("rts_unit"):
			unit.movement.append_navigation(click_position, group_map, path)
	
func camera_control(delta):
	var input_axis:= Vector2(0,0)
	input_axis.x = Input.get_axis("Left", "Right")
	input_axis.y = Input.get_axis("Top", "Bottom")
	var movement = camera_movement if camera_movement != Vector2(0, 0) else input_axis * camera_speed
	if movement != Vector2(0, 0):
		queue_redraw()
	player.position += movement * camera.get_zoom() * delta

func selection_control(event):
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and selected.size() > 0:
			reset_selection()
		if event.pressed:
			set_start_dragging(mouse_pos)
		elif dragging:
			set_stop_dragging(
				mouse_pos, 
				get_world_2d().direct_space_state, 
				func(el): return el.collider.controlled_by == player_id
			)
			queue_redraw()
	if event is InputEventMouseMotion and dragging:
		queue_redraw()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and selected.size() > 0:
			if Input.is_key_pressed(KEY_SHIFT):
				append_unit_action(mouse_pos)
			else:
				command_unit_action(mouse_pos)
			queue_redraw()
	if Input.is_action_pressed("spell_slot_2"):
		GameManager.spawn_character(char_scene, {"position": mouse_pos, "controlled_by": player_id})
	queue_redraw()

@export var char_scene: String = ""

func compute_selected_units(start, end, space, filter_function=null):
	var result
	var query = PhysicsShapeQueryParameters2D.new()
	select_rect.extents = abs(end - start) / 2
	query.shape = select_rect
	query.collision_mask = 2
	query.transform = Transform2D(0, (end + start) / 2)
	if filter_function:
		result = space.intersect_shape(query, 50).filter(filter_function)
	else:
		result = space.intersect_shape(query)
	return result

func _unhandled_input(event):
	selection_control(event)

func _physics_process(delta):
	camera_control(delta)

func _draw():
	if dragging:
		draw_rect(Rect2(to_local(drag_start), get_local_mouse_position() - to_local(drag_start)),
			color, false, 2.0)

func _on_left_mouse_entered():
	camera_movement.x -= camera_speed

func _on_left_mouse_exited():
	camera_movement.x = 0

func _on_right_mouse_entered():
	camera_movement.x += camera_speed

func _on_right_mouse_exited():
	camera_movement.x = 0

func _on_up_mouse_entered():
	camera_movement.y -= camera_speed

func _on_up_mouse_exited():
	camera_movement.y = 0

func _on_down_mouse_entered():
	camera_movement.y += camera_speed

func _on_down_mouse_exited():
	camera_movement.y = 0
