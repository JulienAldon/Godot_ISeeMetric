extends Resource
class_name Damage

@export var base: int # -> skill
@export var added: int # -> equipment & stats
@export var increased: int # -> stats
@export var more: int # -> stats

func calculate():
	return (base + added) * increased * more
