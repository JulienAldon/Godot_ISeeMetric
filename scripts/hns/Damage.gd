extends Resource
class_name Damage

@export var base: float # -> skill
@export var added: float # -> equipment & stats
@export var increased: float # -> stats
@export var more: float # -> stats

func calculate() -> int:
	return floor((base + added) * increased * more)
