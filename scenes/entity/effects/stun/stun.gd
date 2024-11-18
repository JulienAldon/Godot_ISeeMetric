extends Effect

class_name StunEffect

func start(_character):
	super.start(_character)
	if "movement" in character:
		_character.movement.process_mode = PROCESS_MODE_DISABLED

func update(_delta):
	pass

func stop():
	if "movement" in character:
		character.movement.process_mode = PROCESS_MODE_INHERIT
