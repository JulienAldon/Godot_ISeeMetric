const Cell = preload("res://scripts/Navigation/Cell.gd").Cell
const Portal = preload("res://scripts/Navigation/Portal.gd").Portal

class Sector:
	var width: int
	var cells: Array[Cell] = []
	var portals: Array[Portal] = []

	func clone():
		var new_sector = Sector.new(self.width)
		for cell in self.cells:
			new_sector.cells.append(cell.clone())
		for portal in self.portals:
			new_sector.portals.append(portal.clone())
		return new_sector

	func _init(_width):
		self.width = _width

	func get_cells() -> Array[Cell]:
		return cells
	
	func get_portals() -> Array[Portal]:
		return portals

	func get_total_cost() -> int:
		var cost = 0
		for cell in self.cells:
			cost += cell.cost
		return cost

	func add_cell(position, cost, flow=Vector2()):
		var new_cell = Cell.new(position, cost, flow)
		cells.append(new_cell)

	func find_neighbors(cell_index: int) -> Array[Cell]:
		var offsets: Array[Vector2] = [
			Vector2(0, -self.width),
			Vector2(-1, 0),
			Vector2(0, self.width),
			Vector2(1, 0),
			Vector2(-1, -self.width),
			Vector2(-1, self.width),
			Vector2(1, -self.width),
			Vector2(1, self.width),
		]

		var neighbors: Array[Cell] = []
		for offset in offsets:
			var target_id: int = cell_index + offset.x + offset.y
			if target_id < self.cells.size() and target_id >= 0:
				if not (target_id % self.width == self.width - 1 and cell_index % self.width == 0) and not \
						(target_id % self.width == 0 and cell_index % self.width == self.width - 1):
					neighbors.append(self.cells[target_id])
		return neighbors

	func get_nearest_portal(position):
		if self.portals.size() < 1:
			return -1
		var index = 0
		var lowest_distance = position.distance_to(self.portals[0].position)
		for portal in self.portals:
			if position.distance_to(portal.position) < lowest_distance:
				return index
			index += 1
		return -1

	func find_portal(position) -> int:
		var index = 0
		for cell in self.portals:
			if cell.position == position:
				return index
			index+= 1
		return -1

	func find_cell(position) -> int:
		var index = 0
		for cell in self.cells:
			if cell.position == position:
				return index
			index+= 1
		return -1
