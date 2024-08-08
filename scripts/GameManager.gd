extends Node2D

enum Entity {
}

var Players = {}
const entities = {
}

enum KingUnits {
	knight,
}

enum Factions {
	King,
	Mercenary,
	Farmer
}

const factions_attributes = {
	Factions.King: {
		"color": Color.DARK_RED,
		"name": "King"
	},
	Factions.Mercenary: {
		"color": Color.DARK_VIOLET,
		"name": "Mercenary"
	},
	Factions.Farmer: {
		"color": Color.DARK_BLUE,
		"name": "Farmer",
	},
	-1: {
		"color": Color.BLACK,
		"name": ""
	}
}

func get_level_tilemap():
	var node = get_node_or_null("/root/Multiplayer/Level")
	if !node:
		return null
	var level_loaded = node.get_children()
	if level_loaded.size() <= 0:
		return null
	return level_loaded[0].tilemap
