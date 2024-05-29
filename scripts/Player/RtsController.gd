extends Node2D

const Selection = preload("res://scripts/selection.gd")
var selection = Selection.new()

@export var player: Node2D
@export var camera: Camera2D
@export var camera_margin := 50
@export var camera_speed := 800

var camera_movement := Vector2(0,0)

func _ready():
	pass

func reset_selection():
	selection.set_selected_units(false)
	selection.set_selected([])

func get_nearest_target(pos):
	var target_entity = selection.compute_selected_units(
		Vector2(pos.x + 10, pos.y + 10),
		Vector2(pos.x - 10, pos.y - 10),
		get_world_2d().direct_space_state,
		func(el): return str(el.collider.controlled_by).to_int() != multiplayer.get_unique_id()
	)
	return target_entity

func command_unit_action(click_position):
	var nearest_target = get_nearest_target(click_position)
	if len(nearest_target) > 0:
		selection.set_selected_unit_target_entity(nearest_target[0].collider, $"..".tilemap)
	else:
		selection.set_selected_unit_target_position(click_position, $"..".tilemap)
		queue_redraw()
		
func camera_control(delta):
	player.position += camera_movement * camera.get_zoom() * delta

func selection_control(event):
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and selection.selected.size() > 0:
			reset_selection()
		if event.pressed:
			selection.set_start_dragging(mouse_pos)
		elif selection.dragging:
			selection.set_stop_dragging(
				mouse_pos, 
				get_world_2d().direct_space_state, 
				func(el): return str(el.collider.controlled_by).to_int() == multiplayer.get_unique_id()
			)
			queue_redraw()
	if event is InputEventMouseMotion and selection.dragging:
		queue_redraw()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and selection.selected.size() > 0:
			command_unit_action(mouse_pos)

func _unhandled_input(event):
	if str(name).to_int() != multiplayer.get_unique_id():
		return
	selection_control(event)
	if event is InputEventKey and event.keycode == KEY_A:
		if event.is_pressed():
			GameManager.spawn_unit.rpc(get_global_mouse_position(), name)

func _physics_process(delta):
	camera_control(delta)

func _draw():
	if selection.dragging:
		draw_rect(Rect2(to_local(selection.drag_start), get_local_mouse_position() - to_local(selection.drag_start)),
			Color.YELLOW, false, 2.0)

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
