extends BuildMode

class_name GridBuildMode

@export var grid_placement_cell_size: Vector2 = Vector2(24, 16)
@export var build_preview: Sprite2D
@export var shape: Shape2D
var is_cell_occupied: bool = false
var build_preview_last_snapped_position: Vector2

func position_snapped(pos: Vector2):
	return (pos/ grid_placement_cell_size).floor() *  grid_placement_cell_size

func show_build_mode():
	super()

func hide_build_mode():
	super()

func _input(event):
	if not is_build_mode_enabled:
		return
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and not is_cell_occupied:
			PositionConfirmed.emit(position_snapped(get_global_mouse_position()))
		elif not is_cell_occupied:
			is_build_mode_enabled = false

func _process(_delta):
	if is_build_mode_enabled:
		var current_snap = position_snapped(get_global_mouse_position())
		if build_preview_last_snapped_position and build_preview_last_snapped_position != current_snap:
			build_preview.global_position = current_snap
			is_cell_occupied = is_overlapping_entity()
		build_preview_last_snapped_position = current_snap
		build_preview.show()
		if is_cell_occupied:
			build_preview.modulate = Color.DARK_RED
		else:
			build_preview.modulate = Color(1, 1, 1, 1)
	else:
		build_preview.hide()

func is_overlapping_entity():
	var query = PhysicsShapeQueryParameters2D.new()
	var space = get_world_2d().direct_space_state
	query.shape = shape
	query.collision_mask = 2
	query.transform = Transform2D(0, build_preview.global_position)
	var result = space.intersect_shape(query)
	return result.size() > 0
