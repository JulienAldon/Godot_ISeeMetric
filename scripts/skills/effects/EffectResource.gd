extends Resource

class_name EffectResource

@export var effect_path: String
@export var base_duration: float

func serialize() -> Dictionary:
	return {
		"path": effect_path,
		"duration": base_duration
	}
