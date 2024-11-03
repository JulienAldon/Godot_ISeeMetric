extends Node2D

enum td_building_mode {
	Damage,
	Range,
	Health,
}

# Component responsible for mode tracking / changing and apply its effects

var current_mode: td_building_mode = td_building_mode.Damage

func switch_mode(mode: td_building_mode):
	current_mode = mode
