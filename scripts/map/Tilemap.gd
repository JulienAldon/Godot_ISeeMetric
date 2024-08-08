extends TileMap

@export var navigation_region: NavigationRegion2D

enum layers {
	level0 = 0,
	level1 = 1,
	level2 = 2,
}
const boundary_block_atlas_pos = Vector2i(4, 7)
var main_source = 0

func _ready():
	init_boundaries()
	# spawn ressources
	# bake all navigation regions

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
	var used = get_used_cells(layers.level0)
	for spot in used:
		for offset in offsets:
			var current_spot = spot + offset
			if get_cell_source_id(layers.level0, current_spot) == -1:
				set_cell(layers.level0, current_spot, main_source, boundary_block_atlas_pos)

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

func _on_child_entered_tree(node):
	if node.is_in_group("building"):
		navigation_region.bake_navigation_polygon()
