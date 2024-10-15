extends MoveController

class_name MoveUnits

var tilemap: TileMap

func _ready():
	tilemap = GameManager.get_level_tilemap()
	
func command_movement(click_position, target, attack_move, group_map):
	for unit in group_map.values():
		if "movement" in unit:
			var	path = remove_duplicates(tilemap.get_navigation_path(unit.position, click_position))
			unit.command_navigation(click_position, group_map, path)
			if "attack" in unit:
				unit.attack.attack_move = attack_move
				unit.attack.set_target(target)

func append_movement(click_position, group_map):
	for unit in group_map.values():
		if unit is Building:
			continue
		if "movement" in unit:
			var pos = unit.position
			if unit.movement.path.size() > 0:
				pos = unit.movement.path[unit.movement.path.size() - 1]
			var	path = remove_duplicates(tilemap.get_navigation_path(pos, click_position))
			unit.append_navigation(click_position, group_map, path)

func remove_duplicates(items: Array) -> Array:
	var unique = []
	for item in items:
		if not unique.has(item):
			unique.append(item)
	return unique
