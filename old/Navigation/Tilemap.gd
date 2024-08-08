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
const ComputedSector = preload("res://scripts/Navigation/ComputedSector.gd").ComputedSector

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

var cached_flow_tiles: Dictionary = {}

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
	init_navigation_sectors(cells, tilemap_width, navigation_sector_size, navigation_sectors_width * navigation_sectors_height)
	navigation_sectors_astar = init_simple_astar()

func init_navigation_index():
	var index = 0
	for sector in navigation_sectors:
		for cell in sector.cells:
			var sector_pos: Vector2 = Vector2(int(cell.position.x) / navigation_sector_size, int(cell.position.y) / navigation_sector_size)
			navigation_sectors_index[sector_pos] = index
		index += 1

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
	return 1

func init_sector_cells(cells, map_width, sector_size, nb_sectors):
	navigation_sectors = init_sector_array(nb_sectors)
	var index = 0
	for cell in cells:
		var current_x = index % map_width
		var current_y = index / map_width
		var current_sector_x = current_x / sector_size
		var current_sector_y = current_y / sector_size
		var sector_index = current_sector_x + (current_sector_y * (map_width / sector_size))
		var tile_type = get_cell_atlas_coords(0, cell)
		navigation_sectors[sector_index].add_cell(Vector2(cell), get_tile_cost(tile_type))
		index += 1

var debug_portal = []

func find_global_neighbour(start_sector_index:int, cell_pos: Vector2) -> Array[Cell]:
	var offsets: Array[Vector2] = [
		Vector2(0, -1),
		Vector2(-1, 0),
		Vector2(0, 1),
		Vector2(1, 0),
		Vector2(-1, -1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(1, 1),
	]

	var neighbors: Array[Cell] = []
	var cell_index = navigation_sectors[start_sector_index].find_cell(cell_pos)
	var sectors_size = navigation_sectors[start_sector_index].cells.size()
	for offset in offsets:
		var target_pos = cell_pos + offset
		var target_cell_sector_index = find_in_navigation_sectors(target_pos)
		var target_cell_index = navigation_sectors[target_cell_sector_index].find_cell(target_pos)
		if target_cell_index != -1:
			neighbors.append(navigation_sectors[target_cell_sector_index].cells[target_cell_index])
	return neighbors

func global_neighbors_walkable(sectors, index, cell: Cell):
	var direction_map = {
		Vector2(1, 0): [Directions.North],
		Vector2(-1, 0): [Directions.South],
		Vector2(-1, -1): [Directions.South, Directions.West],
		Vector2(1, 1): [Directions.North, Directions.East],
		Vector2(0, -1): [Directions.West],
		Vector2(0, 1): [Directions.East],
		Vector2(-1, 1): [Directions.South, Directions.East],
		Vector2(1, -1): [Directions.North, Directions.West],
	}
	var global_neighbors = find_global_neighbour(index, cell.position)
	var nb_non_walkable = 0
	for neighbour in global_neighbors:
		var direction = Vector2(int(neighbour.position.x - cell.position.x), int(neighbour.position.y - cell.position.y))

		if neighbour.cost > 250 and direction_map[direction].find(cell.facing) != -1:
			nb_non_walkable += 2
		elif neighbour.cost > 250:
			nb_non_walkable += 1
	return false if nb_non_walkable > 2 else true

func get_portal_groups_index(portals: Array) -> Array[int]:
	var portal_groups_index: Array[int] = [0]
	var portal_index = 0
	var nb_groups = 1
	if portals.size() > 0:
		for portal in portals:
			if portal_index + 1 < portals.size():
				if portal.position.distance_to(portals[portal_index + 1].position) > 2:
					portal_groups_index.append(portal_index)
			portal_index += 1
	if portal_index > 0:
		portal_groups_index.append(portal_index - 1)	
	return portal_groups_index

func get_portal_groups(portals: Array, portal_groups_index: Array[int]):
	var portal_groups = init_array(portal_groups_index.size(), [])
	var group_index = 0
	for portal_group_index in portal_groups_index:
		if group_index + 1 < portal_groups_index.size():
			for i in range(portal_group_index, portal_groups_index[group_index + 1]):
				portal_groups[group_index].append(portals[i])
		group_index += 1
	return portal_groups

func init_sector_portals(sector_size):
	var index = 0
	for sector in navigation_sectors:
		var tile_id = 0
		var portals = [[], [], [], []] # W E S N
		for tile in navigation_sectors[index].cells:
			var current_tile_position = Vector2(tile_id % sector_size, tile_id / sector_size)
			if sector.cells[tile_id].cost <= 250:
				var new_tile
				if current_tile_position.x == 0 and (current_tile_position.y != 0 and current_tile_position.y != sector_size - 1):
					new_tile = Portal.new(tile.position, tile.cost, Directions.West)
					if global_neighbors_walkable(navigation_sectors, index, new_tile):
						portals[0].append(new_tile) 
				elif current_tile_position.x == sector_size - 1 and (current_tile_position.y != 0 and current_tile_position.y != sector_size - 1):
					new_tile = Portal.new(tile.position, tile.cost, Directions.East)
					if global_neighbors_walkable(navigation_sectors, index, new_tile):
						portals[1].append(new_tile)
				elif current_tile_position.y == 0 and (current_tile_position.x != 0 and current_tile_position.x != sector_size - 1):
					new_tile = Portal.new(tile.position, tile.cost, Directions.South)
					if global_neighbors_walkable(navigation_sectors, index, new_tile):
						portals[2].append(new_tile)
				elif current_tile_position.y == sector_size - 1 and (current_tile_position.x != 0 and current_tile_position.x != sector_size - 1):
					new_tile = Portal.new(tile.position, tile.cost, Directions.North)
					if global_neighbors_walkable(navigation_sectors, index, new_tile):
						portals[3].append(new_tile)
			tile_id += 1
		debug_portal.append(portals)
		for border in portals:
			# get portal_groups
			if border.size() > 0:
				var portal_groups_index = get_portal_groups_index(border)
				var portal_groups = get_portal_groups(border, portal_groups_index)
				for group in portal_groups:
					if group.size() > 0:
						var midle_tile = group[group.size() / 2]
						if group.size() == 1:
							midle_tile = group[0]
						navigation_sectors[index].portals.append(midle_tile)
		#if not sector.cells.has(255) and not sector.has(254):
			#navigation_sectors[index].cells = [1] #mark sector as "clear" if no obstacles
		index+= 1
	return navigation_sectors

func init_navigation_sectors(cells, map_width, sector_size, nb_sectors):
	init_sector_cells(cells, map_width, sector_size, nb_sectors)
	init_navigation_index()
	init_sector_portals(sector_size)

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
			if p.position.distance_to(portal.position) <= 3 and p.position != portal.position: # XXX: can cause some bugs in future
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

func get_sectors_index_path(source, target):
	var source_sector_id = find_in_navigation_sectors(source)
	var target_sector_id = find_in_navigation_sectors(target)
	if source_sector_id == -1 or target_sector_id == -1:
		return [-1]
	var source_sector = navigation_sectors[source_sector_id]
	var target_sector = navigation_sectors[target_sector_id]
	var existing_points = navigation_sectors_astar.get_point_ids()
	var source_id = existing_points.size()
	var target_id = existing_points.size() + 1

	navigation_sectors_astar.add_point(source_id, source, 1)
	navigation_sectors_astar.add_point(target_id, target, 0)
	#connects sector portals
	for portal in source_sector.portals:
		navigation_sectors_astar.connect_points(portal.index, source_id)
	for portal in target_sector.portals:
		navigation_sectors_astar.connect_points(portal.index, target_id)
	#source_sector.portals[source_sector.get_nearest_portal(source)].index
	#var target_portal_index = navigation_sectors_astar.get_closest_point(target)
	#target_sector.portals[target_sector.get_nearest_portal(target)].index
	var result = navigation_sectors_astar.get_point_path(source_id, target_id)
	navigation_sectors_astar.remove_point(source_id)
	navigation_sectors_astar.remove_point(target_id)
	return result

func compute_navigation(target_position: Vector2, sources):
	var target_sector = find_in_navigation_sectors(target_position)
	var sector_index_path = []
	var output_portals_position: Array[Vector2] = []
	var computed_sectors: Array[ComputedSector] = []
	#var flow_atlas = init_sector_array(navigation_sectors_width * navigation_sectors_height)
	var calculated_source = []
	for source in sources:
		var source_position = Vector2(local_to_map(source.collider.position))
		var source_sector_id = find_in_navigation_sectors(source_position)
		if calculated_source.has(source_sector_id):
			continue
		var path = Array(get_sectors_index_path(source_position, target_position))
		calculated_source.append(source_sector_id)
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
		if tile == target_sector:
			target = target_position
		if !cached_flow_tiles.get(tile) or (cached_flow_tiles.get(tile) and target != cached_flow_tiles.get(tile).output):
			var flow_sector = calculate_navigation_sector(tile, target)
			var computed_sector = ComputedSector.new(tile, target, flow_sector)
			computed_sectors.append(computed_sector)
			cached_flow_tiles[tile] = computed_sector
		elif target == cached_flow_tiles.get(tile).output:
			var computed_sector = cached_flow_tiles.get(tile)
			computed_sectors.append(computed_sector)
		i += 1
	return computed_sectors

func request_navigation_path(target_position, sources):
	target_position = Vector2(local_to_map(target_position))	
	var flow_atlas = init_sector_array(navigation_sectors_width * navigation_sectors_height)
	var computed_sectors = compute_navigation(target_position, sources)
	for computed_sector in computed_sectors:
		flow_atlas[computed_sector.index] = computed_sector.sector
	return flow_atlas

func calculate_integration_field_djikstra(target_id, sector: Sector):
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

func calculate_flow_vectors(sector: Sector) -> Sector:
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

func calculate_navigation_sector(sector_index: int, cell_pos: Vector2):
	var target_index = navigation_sectors[sector_index].find_cell(cell_pos)
	var flow_field: Sector = calculate_integration_field_djikstra(target_index, navigation_sectors[sector_index].clone())
	flow_field = calculate_flow_vectors(flow_field)
	return flow_field

func find_in_navigation_sectors(pos):
	var sector_pos = Vector2(int(pos.x / navigation_sector_size), int(pos.y / navigation_sector_size))
	return navigation_sectors_index.get(sector_pos, -1)

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
