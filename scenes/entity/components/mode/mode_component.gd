extends Node2D

enum BuildingMode {
	DAMAGE,
	RANGE,
	HEALTH,
}

# Component responsible for mode tracking / changing and apply its effects

var current_mode: BuildingMode = BuildingMode.DAMAGE

func switch_mode(mode: BuildingMode):
	current_mode = mode
