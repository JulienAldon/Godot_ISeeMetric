class Cell:
	func _init(_position, _cost, _flow=Vector2()):
		self.position = _position
		self.cost = _cost
		self.flow = _flow

	func clone():
		return Cell.new(self.position, self.cost, self.flow)

	var position: Vector2
	var cost: int
	var flow: Vector2
	
