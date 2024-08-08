const Portal = preload("res://scripts/Navigation/Portal.gd").Portal
const Sector = preload("res://scripts/Navigation/Sector.gd").Sector

class ComputedSector:
	func _init(_sector_index: int, _output_portal: Vector2, _sector: Sector):
		self.output = _output_portal
		self.index = _sector_index
		self.sector = _sector

	var output: Vector2
	var index: int
	var sector: Sector
