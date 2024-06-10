const Cell = preload("res://scripts/Navigation/Cell.gd").Cell

enum Directions {
	North,
	South,
	East,
	West
}

class Portal extends Cell:
	func _init(_position, _cost, _facing, _index=0, _flow=Vector2()):
		super(_position, _cost, _flow)
		self.index = index
		self.facing = _facing

	func get_facing_vector():
		if facing == Directions.North:
			return Vector2(0, -1)
		if facing == Directions.South:
			return Vector2(0, 1)
		if facing == Directions.East:
			return Vector2(-1, 0)
		if facing == Directions.West:
			return Vector2(1, 0)
		return Vector2(0, -1)
		
	func clone():
		return Portal.new(self.position, self.cost, self.facing, self.index, self.flow)

	var facing: Directions # N S E O
	var index: int
