extends MoveController

class_name MoveCharacter

@export var camera: Camera2D

func move(entities, input_axis):
	for child in entities:
		child.movement.set_input_axis(input_axis)
	if entities.size() > 0:
		var pos = entities[0].position
		camera.position = pos
