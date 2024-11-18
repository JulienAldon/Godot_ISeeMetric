extends TileMapLayer

@export var navigation_region: NavigationRegion2D

const boundary_block_atlas_pos = Vector2i(4, 7)
const floor_atlas_pos = Vector2i(2, 6)
const wall_floor_atlas_pos = Vector2i(2, 2)

var main_source = 0

func _ready():
	init_boundaries()

func init_boundaries():
	var offsets = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(-1, -1),
		Vector2i(1, 1),
		Vector2i(-1, 1),
		Vector2i(1, -1),
	]
	var used = get_used_cells()
	for spot in used:
		for offset in offsets:
			var current_spot = spot + offset
			if get_cell_source_id(current_spot) == -1:
				set_cell(current_spot, main_source, boundary_block_atlas_pos)

func get_navigation_path(p_start_position: Vector2, p_target_position: Vector2) -> PackedVector2Array:
	if not is_inside_tree():
		return PackedVector2Array()

	var default_map_rid: RID = get_world_2d().get_navigation_map()
	var path: PackedVector2Array = NavigationServer2D.map_get_path(
		default_map_rid,
		p_start_position,
		p_target_position,
		true
	)
	return path

func bake_navigation():
	if not navigation_region.is_baking():
		navigation_region.bake_navigation_polygon()
