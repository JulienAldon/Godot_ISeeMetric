extends TileMap

enum layers {
	level0 = 0,
	level1 = 1,
	level2 = 2,
}

const Sector = preload("res://scripts/Navigation/Sector.gd").Sector
const Portal = preload("res://scripts/Navigation/Portal.gd").Portal
const Directions = preload("res://scripts/Navigation/Portal.gd").Directions
const Cell = preload("res://scripts/Navigation/Cell.gd").Cell

const boundary_block_atlas_pos = Vector2i(2, 8)
var main_source = 0
var tilemap_width = 0
var tilemap_height = 0

var navigation_sectors_width = 0
var navigation_sectors_height = 0
var navigation_sectors_astar: AStar2D
var navigation_sector_size = 16

var navigation_sectors_index: Dictionary = {}
var navigation_sectors: Array[Sector] = []

func get_tilemap_cells():
	var tilemap_cells = get_used_cells(layers.level0)
	tilemap_cells.sort()
	return tilemap_cells

func _ready():
	init_boundaries()
	var cells = get_tilemap_cells()
	tilemap_width = get_used_rect().size.y
	tilemap_height = get_used_rect().size.x
	navigation_sectors_width = tilemap_width / navigation_sector_size
	navigation_sectors_height = tilemap_height / navigation_sector_size
	navigation_sectors = init_navigation_sectors(cells, tilemap_width, navigation_sector_size, navigation_sectors_width * navigation_sectors_height)
	navigation_sectors_index = init_navigation_index()
	navigation_sectors_astar = init_simple_astar()

func init_navigation_index():
	var result: Dictionary = {}
	var index = 0
	for sector in navigation_sectors:
		for cell in sector.cells:
			var sector_pos: Vector2 = Vector2(int(cell.position.x) / navigation_sector_size, int(cell.position.y) / navigation_sector_size)
			result[sector_pos] = index
		index += 1
	return result

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

func get_tile_cost(tile_type):
	if tile_type == Vector2i(2, 8) or tile_type == Vector2i(1, 2):
		return 255
	elif tile_type == Vector2i(0, 3):
		return 254
	return 1

func init_sector_cells(cells, map_width, sector_size, nb_sectors):
	var sectors: Array[Sector] = init_sector_array(nb_sectors)
	var index = 0
	for cell in cells:
		var current_x = index % map_width
		var current_y = index / map_width
		var current_sector_x = current_x / sector_size
		var current_sector_y = current_y / sector_size
		var sector_index = current_sector_x + (current_sector_y * (map_width / sector_size))
		var tile_type = get_cell_atlas_coords(0, cell)
		sectors[sector_index].add_cell(Vector2(cell), get_tile_cost(tile_type))
		index += 1
	return sectors

var debug_portal = []

func find_global_sector_cell(sectors, sector_index, cell_index, cell_offset, sector_offset):
	if sectors.size() > sector_index + sector_offset:
		var current_cell = sectors[sector_index].cells[cell_index].position
		var current_y_offset = 0
		if cell_offset.y > 0:
			current_y_offset = 1
		elif cell_offset.y < 0:
			current_y_offset = -1
		var neighbour_cell = sectors[sector_index + sector_offset].find_cell(Vector2(current_cell.x+current_y_offset, current_cell.y+cell_offset.x))
		return sectors[sector_index + sector_offset].cells[neighbour_cell]

func find_global_neighbour(sectors: Array[Sector], start_sector_index:int, cell_pos: Vector2) -> Array[Cell]:
		var offsets: Array[Vector2] = [
			Vector2(0, -navigation_sector_size),
			Vector2(-1, 0),
			Vector2(0, navigation_sector_size),
			Vector2(1, 0),
			Vector2(-1, -navigation_sector_size),
			Vector2(-1, navigation_sector_size),
			Vector2(1, -navigation_sector_size),
			Vector2(1, navigation_sector_size),
		]

		var neighbors: Array[Cell] = []
		var cell_index = sectors[start_sector_index].find_cell(cell_pos)
		var previous_size = 0
		for offset in offsets:
			var target_id: int = cell_index + offset.x + offset.y
			if target_id < sectors[start_sector_index].cells.size() and target_id >= 0:
				if not (target_id % navigation_sector_size == navigation_sector_size - 1 and cell_index % navigation_sector_size == 0) and not \
					(target_id % navigation_sector_size == 0 and cell_index % navigation_sector_size == navigation_sector_size - 1):
					neighbors.append(sectors[start_sector_index].cells[target_id])
			if neighbors.size() == previous_size:
				var cell
				# TODO find what is overflowing x or y
				if offset.x > 0:
					cell = find_global_sector_cell(sectors, start_sector_index, cell_index, offset, 1)
				if offset.x < 0:
					cell = find_global_sector_cell(sectors, start_sector_index, cell_index, offset, -1)
				#if offset.y > 0:
					#cell = find_global_sector_cell(sectors, start_sector_index, cell_index, offset, navigation_sectors_width)
				#if offset.y < 0:
					#cell = find_global_sector_cell(sectors, start_sector_index, cell_index, offset, -navigation_sectors_width)
				if cell:
					neighbors.append(cell)
			previous_size = neighbors.size()
		return neighbors

func init_sector_portals(sectors, sector_size):
	var index = 0
	for sector in sectors:
		var tile_id = 0
		var portals = [[], [], [], []] # N S E O
		for tile in sectors[index].cells:
			var current_tile_position = Vector2(tile_id % sector_size, tile_id / sector_size)
			if sector.cells[tile_id].cost <= 10:
				if current_tile_position.x == 0 and (current_tile_position.y != 0 and current_tile_position.y != sector_size - 1):
					var new_tile = Portal.new(tile.position, tile.cost, Directions.North)
					portals[0].append(new_tile) 
				elif current_tile_position.x == sector_size - 1 and (current_tile_position.y != 0 and current_tile_position.y != sector_size - 1):
					var new_tile = Portal.new(tile.position, tile.cost, Directions.South)
					portals[1].append(new_tile)
				elif current_tile_position.y == 0 and (current_tile_position.x != 0 and current_tile_position.x != sector_size - 1):
					var new_tile = Portal.new(tile.position, tile.cost, Directions.East)
					portals[2].append(new_tile)
				elif current_tile_position.y == sector_size - 1 and (current_tile_position.x != 0 and current_tile_position.x != sector_size - 1):
					var new_tile = Portal.new(tile.position, tile.cost, Directions.West)
					portals[3].append(new_tile)
			tile_id += 1
		debug_portal.append(portals)
		for portal in portals:
			if portal.size() > 0:
				
				var midle_tile = portal[portal.size() / 2]
				var n = find_global_neighbour(sectors, index, midle_tile.position)
				for a in n:
					print("midle tile: ", midle_tile.position, " neigbour: ", a.position)
				sectors[index].portals.append(midle_tile)
		#if not sector.cells.has(255) and not sector.has(254):
			#sectors[index].cells = [1] #mark sector as "clear" if no obstacles
		index+= 1
	return sectors

func init_navigation_sectors(cells, map_width, sector_size, nb_sectors):
	var sectors: Array[Sector] = init_sector_cells(cells, map_width, sector_size, nb_sectors)
	return init_sector_portals(sectors, sector_size)

func astar_connect_portals_inside_sector(portals: Array[Portal], astar: AStar2D):
	for portal in portals:
		for p in portals:
			if portal.index != p.index:
				if !astar.are_points_connected(portal.index, p.index):
					astar.connect_points(portal.index, p.index)
	return astar

func astar_connect_portals_between_sectors(portals: Array[Portal], astar: AStar2D):
	for portal in portals:
		for p in portals:
			if p.position.distance_to(portal.position) <= 4 and p.position != portal.position: # XXX: can cause some bugs in future
				if !astar.are_points_connected(portal.index, p.index):
					astar.connect_points(p.index, portal.index)
	return astar

func init_simple_astar():
	var astar = AStar2D.new()
	var portal_graph: Array[Portal] = []
	var index: int = 0

	for sector in self.navigation_sectors:
		for portal in sector.portals:
			astar.add_point(index, portal.position, sector.get_total_cost())
			portal.index = index
			portal_graph.append(portal)
			index += 1
		astar = astar_connect_portals_inside_sector(sector.portals, astar)
	astar = astar_connect_portals_between_sectors(portal_graph, astar)
	return astar

func find_portal_index(sector_index: int):
	var portal_index: int = 0
	for index in range(navigation_sectors.size()):
		if index == sector_index:
			return portal_index
		portal_index += navigation_sectors[index].portals.size()
	return -1

func get_sectors_index_path(source, target):
	var source_sector_id = find_in_navigation_sectors(source)
	var target_sector_id = find_in_navigation_sectors(target)
	if source_sector_id == -1 or target_sector_id == -1:
		return [-1]
	var source_sector = navigation_sectors[source_sector_id]
	var target_sector = navigation_sectors[target_sector_id]
	var source_portal_index = source_sector.portals[source_sector.get_nearest_portal(source)].index
	var target_portal_index = target_sector.portals[target_sector.get_nearest_portal(target)].index
	return navigation_sectors_astar.get_point_path(source_portal_index, target_portal_index)

func find_sector_portal_output():
	pass

func compute_navigation(target_position: Vector2, sources):
	var sector_index_path = []
	debug_sector = []
	var output_portals_position: Array[Vector2] = []
	var flow_atlas = init_sector_array(navigation_sectors_width * navigation_sectors_height)
	target_position = Vector2(local_to_map(target_position))	
	
	for source in sources:
		var path = Array(get_sectors_index_path(Vector2(local_to_map(source.collider.position)), target_position))
		if path == [-1]:
			return [-1]
		path.append(target_position)
		var sectors_index = path.map(func(el): return find_in_navigation_sectors(el)) 
		var path_index = 0
		for p in path:
			if (path_index + 1 < sectors_index.size() and sectors_index[path_index] != sectors_index[path_index + 1]):
				if !output_portals_position.has(p):
					output_portals_position.append(p)
				if !sector_index_path.has(sectors_index[path_index]):
					sector_index_path.append(sectors_index[path_index])
			path_index += 1

		if !output_portals_position.has(path[path_index - 1]):
			output_portals_position.append(path[path_index - 1])
		if !sector_index_path.has(sectors_index[path_index - 1]):
			sector_index_path.append(sectors_index[path_index - 1])
	var i = 0
	for tile in sector_index_path:
		var target = output_portals_position[i]
		if i == sector_index_path.size() - 1:
			target = target_position
		var flow_tile = calculate_navigation_sector(tile, target)
		flow_atlas[tile].width = flow_tile.width
		flow_atlas[tile].cells = flow_tile.cells
		flow_atlas[tile].portals = flow_tile.portals
		i += 1
	return flow_atlas

func calculate_integration_field_djikstra(target_id, sector):
	var final_map: Array[Cell] = []
	for cell in sector.cells:
		final_map.append(cell.clone())
	final_map.map(func(cell): cell.cost = 65535)
	final_map[target_id].cost = 0
	var open_list = []
	open_list.append(target_id)
	while (open_list.size() > 0):
		var current_id = open_list.front()
		open_list.pop_front()
		var neighbors = sector.find_neighbors(current_id)
		for neighbour in neighbors:
			var neighbour_cost = final_map[current_id].cost + neighbour.cost
			var neighbour_index = sector.find_cell(neighbour.position)
			if neighbour_index < final_map.size() and neighbour_cost < final_map[neighbour_index].cost:
				if !open_list.has(neighbour_index):
					open_list.push_back(neighbour_index)
				final_map[neighbour_index].cost = neighbour_cost
	sector.cells = final_map
	return sector

func calculate_flow_vectors(sector):
	for index in range(0, sector.cells.size()):
		var neighbors: Array[Cell] = sector.find_neighbors(index)
		var nearest_neighbour: Cell = get_minimum_weight(neighbors, sector.cells[index].cost)
		var current_pos: Vector2 = sector.cells[index].position
		sector.cells[index].flow = nearest_neighbour.position - current_pos
		var portal_index = sector.find_portal(current_pos)
		if sector.cells[index].cost == 0 and portal_index != -1:
			var portal = sector.portals[portal_index]
			sector.cells[index].flow = portal.get_facing_vector()
	return sector

var debug_sector = []

func calculate_navigation_sector(sector_index: int, cell_pos: Vector2):
	var target_index = navigation_sectors[sector_index].find_cell(cell_pos)
	var flow_field = calculate_integration_field_djikstra(target_index, navigation_sectors[sector_index].clone())
	debug_sector.append(flow_field)
	$"../DebugTilemap".queue_redraw()
	flow_field = calculate_flow_vectors(flow_field)
	return flow_field

func find_in_navigation_sectors(pos):
	var sector_pos = Vector2(int(pos.x / navigation_sector_size), int(pos.y / navigation_sector_size))
	return navigation_sectors_index[sector_pos]

func get_minimum_weight(neighbors, current_weight):
	var min_weight = current_weight
	var min_cell_index = 0
	for i in range(0, neighbors.size()):
		if min_weight > neighbors[i].cost:
			min_weight = neighbors[i].cost
			min_cell_index = i
	return neighbors[min_cell_index]

func init_array(size, value):
	var array = []
	array.resize(size)
	for p in range(array.size()):
		array[p] = value.duplicate()
	return array

func init_sector_array(size):
	var array: Array[Sector] = []
	array.resize(size)
	for p in range(array.size()):
		var new_sector = Sector.new(navigation_sector_size)
		array[p] = new_sector
	return array
