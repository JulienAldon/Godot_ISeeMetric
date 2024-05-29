extends TileMap

enum layers {
	level0 = 0,
	level1 = 1,
	level2 = 2,
}

const boundary_block_atlas_pos = Vector2i(2, 8)
var main_source = 0
var tilemap_width = 0
var tilemap_height = 0

var navigation_sectors_cost_field = []
var navigation_sectors_positions = []
var navigation_sectors_portals = []
var navigation_sectors_width = 0
var navigation_sectors_height = 0
var navigation_sectors_astar
var navigation_sector_size = 10
var tilemap_cells

func get_navigation_sectors():
	return [navigation_sectors_cost_field, navigation_sectors_positions]

func get_tilemap_cells():
	tilemap_cells = get_used_cells(layers.level0)
	tilemap_cells.sort()
	return tilemap_cells

func _ready():
	init_boundaries()
	var cells = get_tilemap_cells()
	tilemap_width = get_used_rect().size.y
	tilemap_height = get_used_rect().size.x
	navigation_sectors_width = tilemap_width / navigation_sector_size
	navigation_sectors_height = tilemap_height / navigation_sector_size
	var navigation_sectors = init_navigation_sectors(cells, tilemap_width, tilemap_height, navigation_sector_size)
	navigation_sectors_cost_field = navigation_sectors[0]
	navigation_sectors_positions = navigation_sectors[1]
	navigation_sectors_portals = navigation_sectors[2]
	navigation_sectors_astar = init_simple_astar(navigation_sectors_cost_field, navigation_sectors_portals, navigation_sectors_width)

func get_tile_cost(tile_type):
	if tile_type == Vector2i(2, 8) or tile_type == Vector2i(1, 2):
		return 255
	elif tile_type == Vector2i(0, 3):
		return 254
	return 1
	
var sectors_portals_tile

func init_navigation_sectors(cells, map_width, map_height, sector_size):
	# parse all cells
	var sectors_size = (map_width / sector_size) * (map_height / sector_size)
	var positions = init_array(sectors_size, [])
	var sectors = init_array(sectors_size, [])
	var sectors_portals = init_array(sectors_size, [])
	sectors_portals_tile = init_array(sectors_size, [])
	var index = 0
	for cell in cells:
		var current_x = index % map_width
		var current_y = index / map_width
		var current_sector_x = current_x / sector_size
		var current_sector_y = current_y / sector_size
		var sector_index = current_sector_x + (current_sector_y * (map_width / sector_size))
		var tile_type = get_cell_atlas_coords(0, cell)
		sectors[sector_index].append(get_tile_cost(tile_type))
		positions[sector_index].append(Vector2(cell))
		index += 1
	index = 0
	for sector in sectors:
		var tile_id = 0
		var portals = [[], [], [], []] # N S E O
		for tile in positions[index]:
			var current_tile_position = Vector2(tile_id % sector_size, tile_id / sector_size)
			if sector[tile_id] <= 10:
				if current_tile_position.x == 0 and (current_tile_position.y != 0 and current_tile_position.y != sector_size - 1):
					portals[0].append(tile) 
				elif current_tile_position.x == sector_size - 1 and (current_tile_position.y != 0 and current_tile_position.y != sector_size - 1):
					portals[1].append(tile)
				elif current_tile_position.y == 0 and (current_tile_position.x != 0 and current_tile_position.x != sector_size - 1):
					portals[2].append(tile)
				elif current_tile_position.y == sector_size - 1 and (current_tile_position.x != 0 and current_tile_position.x != sector_size - 1):
					portals[3].append(tile)
			tile_id += 1
		sectors_portals_tile[index] = portals
		for portal in portals:
			if portal.size() > 0:
				var midle_tile = portal[portal.size() / 2]
				sectors_portals[index].append(midle_tile)
		if not sector.has(255) and not sector.has(254):
			sectors[index] = [1] #mark sector as "clear" if no obstacles
		index+= 1
	return [sectors, positions, sectors_portals]

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

func get_neighbors(index, map, map_width):
	var offsets = [
		Vector2(0, -map_width),
		Vector2(-1, 0),
		Vector2(0, map_width),
		Vector2(1, 0),
		Vector2(-1, -map_width),
		Vector2(-1, map_width),
		Vector2(1, -map_width),
		Vector2(1, map_width),
	]
	var neighbors = []
	for offset in offsets:
		var target_id = index + offset.x + offset.y
		if target_id < map.size() and target_id >= 0:
			neighbors.append(target_id)
	return neighbors

func init_simple_astar(map_cost, map_portal, map_width):
	var astar = AStar2D.new()
	var index = 0
	var sector_index = 0
	var portal_graph = []
	for sector in map_portal:
		var previous_portal = 0
		for portal in sector:
			astar.add_point(index, portal, map_cost[sector_index].reduce(func (acc, num): return acc + num))
			portal_graph.append(portal)
			if previous_portal != index:
				astar.connect_points(previous_portal, index)
			previous_portal = index
			index += 1
		sector_index += 1
	for id in range(portal_graph.size()):
		var current = portal_graph[id]
		var nearest_id = 0
		for portal in portal_graph:
			if portal.distance_to(current) <= 4 and portal != current: # XXX: can cause some bugs in future
				astar.connect_points(id, nearest_id)
				print(portal, " ", current)
			nearest_id += 1
	return astar
	
func get_sectors_path(source_position, target_position):
	var source_position_sector_id = find_in_navigation_sectors(source_position)
	var target_position_sector_id = find_in_navigation_sectors(target_position)
	return navigation_sectors_astar.get_point_path(source_position_sector_id, target_position_sector_id)

func find_in_navigation_sectors(pos):
	var index = 0
	for sector in navigation_sectors_positions:
		var id = sector.find(pos)
		if id != -1:
			return index
		index+= 1
	return -1

func flat_and_remove_duplicates(tiles):
	var result = []
	for tile_row in tiles:
		for tile in tile_row:
			if not result.has(tile):
				result.append(tile)	
	return result

func calculate_flow_field(target_position, sources):
	var path_tiles = []
	var flow_atlas = []
	target_position = Vector2(local_to_map(target_position))
	for source in sources:
		var path = Array(get_sectors_path(Vector2(local_to_map(source.collider.position)), target_position))
		print(path)
		var index_path = path.map(func(el): return el.x + (el.y * navigation_sectors_width))
		path_tiles.append(index_path)
	path_tiles = flat_and_remove_duplicates(path_tiles)
	for tile in path_tiles:
		flow_atlas.append(get_flow_tile([navigation_sectors_cost_field[tile], navigation_sectors_positions[tile]], navigation_sector_size, target_position))
	print(flow_atlas)	
	return flow_atlas
	
func get_neighbors_pos(index, map, map_width, map_pos):
	var offsets = [
		Vector2(0, -map_width),
		Vector2(-1, 0),
		Vector2(0, map_width),
		Vector2(1, 0),
		Vector2(-1, -map_width),
		Vector2(-1, map_width),
		Vector2(1, -map_width),
		Vector2(1, map_width),
	]
	var neighbor_width = []
	var neighbor_pos = []
	for offset in offsets:
		var target_id = index + offset.x + offset.y
		if target_id < map.size() and target_id >= 0:
			neighbor_width.append(map[target_id])
			neighbor_pos.append(map_pos[target_id])
	return [neighbor_width, neighbor_pos]
	
func calculate_integration_field_djikstra(target_id, cost_map, map_width):
	var final_map = cost_map[0].map(func (_tile): return 65535)
	final_map[target_id] = 0
	var open_list = []
	open_list.append(target_id)
	while (open_list.size() > 0):
		var current_id = open_list.front()
		open_list.pop_front()
		var neighbors = get_neighbors_pos(current_id, cost_map[0], map_width, cost_map[1])
		for i in range(0, neighbors[0].size()):
			var neighbor_cost = final_map[current_id] + neighbors[0][i]
			var neighbor_pos = neighbors[1][i]
			var current_cost_index = cost_map[1].find(neighbor_pos)
			if current_cost_index < final_map.size() and neighbor_cost < final_map[current_cost_index]:
				if !open_list.has(current_cost_index):
					open_list.push_back(current_cost_index)
				final_map[current_cost_index] = neighbor_cost
	return final_map

func get_minimum_weight_neigbor(neighbors, current_weight):
	var min_weight = current_weight
	var min_index = 0
	for i in range(0, neighbors.size()):
		if min_weight > neighbors[i]:
			min_weight = neighbors[i]
			min_index = i
	return [min_weight, min_index]

func calculate_flow_map(integration_map, map_width, positions):	
	var flow_field = []
	for index in range(0, integration_map.size()):
		var neighbors = get_neighbors_pos(index, integration_map, map_width, positions)
		var neighbor = get_minimum_weight_neigbor(neighbors[0], integration_map[index])
		var neighbor_index = positions.find(neighbors[1][neighbor[1]])
		var current_pos = positions[index]
		var neighbor_pos = positions[neighbor_index]
		flow_field.append(neighbor_pos - current_pos)
	return flow_field

func get_flow_tile(cost_field, tile_size, cell_pos):
	var target_pos_index = cost_field[1].find(cell_pos)
	var integration_field = calculate_integration_field_djikstra(target_pos_index, cost_field, tile_size)
	return [calculate_flow_map(integration_field, tile_size, cost_field[1]), cost_field[1]]

func init_array(size, value):
	var array = []
	array.resize(size)
	for p in range(array.size()):
		array[p] = value.duplicate()
	return array
