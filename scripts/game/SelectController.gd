extends Node2D

class_name SelectController

@export var controller: Controller

var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()
var selected = []
var dragging = false

func get_selected():
	return selected

func clear_selected():
	for unit in selected:
		if not is_instance_valid(unit) or ("death" in unit and unit.death.is_dead):
			selected.erase(unit)

func set_start_dragging(pos):
	dragging = true
	drag_start = pos

func set_stop_dragging(stop, space, filter_func):
	dragging = false
	set_selected(compute_selected_units(drag_start, stop, space, filter_func))
	if selected.size() > 0:
		pass
		controller.player.show_entities_informations(selected, controller.player_id)
		controller.player.show_entities_actions(selected, controller.player_id)
	set_selected_units(true)

func set_selected_units(status):
	for unit in selected:
		if is_instance_valid(unit):
			if unit.is_in_group("rts_unit") and ("death" in unit and not unit.death.is_dead):
				unit.selection.set_selected(status)

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
		func(el): return str(el.collider.controlled_by).to_int() != controller.player_id
	)
	return target_entity

func compute_selected_units(start, end, space, filter_function=null):
	var result
	var query = PhysicsShapeQueryParameters2D.new()
	select_rect.extents = abs(end - start) / 2
	query.shape = select_rect
	query.collision_mask = 2
	query.transform = Transform2D(0, (end + start) / 2)
	if filter_function:
		result = space.intersect_shape(query, 1000).filter(filter_function)
	else:
		result = space.intersect_shape(query)
	return result.map(func(el): return el.collider).filter(func(el): return is_instance_valid(el))

func calculate_mean_position(group):
	var mean_pos := Vector2(0, 0)
	
	for unit in group:
		if is_instance_valid(unit):
			mean_pos += unit.position
	mean_pos /= group.size()
	return mean_pos

func drag_and_click(event, mouse_pos: Vector2):
	if event.pressed and selected.size() > 0:
		reset_selection()
	if event.pressed:
		set_start_dragging(mouse_pos)
	elif dragging:
		set_stop_dragging(
			mouse_pos, 
			get_world_2d().direct_space_state, 
			func(el): return el.collider.controlled_by == controller.player_id
		)
		queue_redraw()

func selection_control(event):
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseMotion and dragging:
		queue_redraw()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drag_and_click(event, mouse_pos)
	queue_redraw()

func create_selected_map():
	var group_map = {}
	for unit in selected:
		group_map[unit.get_instance_id()] = unit
	return group_map

func create_unit_group(path, click_position, target, group_map):
	var unit_group = UnitGroup.new()
	unit_group.members = group_map
	unit_group.path = path
	unit_group.target_position = click_position
	unit_group.target = target
	return unit_group

func _draw():
	if selected.size() > 0:
		if is_instance_valid(selected[0]) and not selected[0] is Building:
			if "attack" in selected[0] and selected[0].attack.target:
				return
			if not "movement" in selected[0]:
				return
			var unit = selected[0].movement
			var path = unit.path
			var pos = calculate_mean_position(selected.filter(func(el): return not el is Building))
			if path.size() > 0:
				var index = 0
				var new_path = path.slice(unit.current_path_position, path.size())
				new_path.append(unit.target_position)
				for a in new_path:
					var first_step = a
					if index == 0:
						first_step = pos
					if index < new_path.size() - 1:
						draw_dashed_line(to_local(first_step), to_local(new_path[index + 1]), Color(11, 11, 11, 0.7), 2, 3)
					index += 1
	for elem in selected:
		if is_instance_valid(elem) and elem is Building and not elem is Outpost:
			draw_dashed_line(to_local(elem.global_position), to_local(elem.movement.target_position), Color(11, 11, 11, 0.7), 2, 3)
	if dragging:
		draw_rect(Rect2(to_local(drag_start), get_local_mouse_position() - to_local(drag_start)), controller.color, false, 2.0)
	# shaw nb selected
