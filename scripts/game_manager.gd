extends Node2D

enum CurrencyType {
	GOLD,
	FAITH,
	WOOD,
	STONE,
	WHEAT,
}

var Players = {}


enum Factions {
	KING,
	MERCENARY,
	FARMER,
	CHURCH,
}

const factions_attributes = {
	Factions.KING: {
		"color": [Color.DARK_RED, Color.DARK_MAGENTA, Color.DARK_SLATE_BLUE],
		"name": "King"
	},
	Factions.MERCENARY: {
		"color": [Color.DARK_VIOLET, Color.DARK_CYAN, Color.DARK_GOLDENROD],
		"name": "Mercenary"
	},
	Factions.FARMER: {
		"color": [Color.DARK_KHAKI, Color.DARK_ORANGE, Color.DARK_GRAY],
		"name": "Farmer",
	},
	-1: {
		"color": [Color.BLACK],
		"name": ""
	},
}

func set_player_experience(player_id, value):
	var player = get_node_or_null("/root/Multiplayer/Network/"+str(player_id))
	if not player:
		return null
	player.set_experience.rpc_id(player_id, value)

func get_level_outposts():
	var node = get_node_or_null("/root/Multiplayer/Level")
	if !node:
		return null
	var level_loaded = node.get_children()
	if level_loaded.size() <= 0:
		return null
	return level_loaded[0].get_outposts()

func get_level_fog():
	var node = get_node_or_null("/root/Multiplayer/Level")
	if !node:
		return null
	var level_loaded = node.get_children()
	if level_loaded.size() <= 0:
		return null
	return level_loaded[0].get_fog()

func get_level_tilemap():
	var node = get_node_or_null("/root/Multiplayer/Level")
	if !node:
		return null
	var level_loaded = node.get_children()
	if level_loaded.size() <= 0:
		print("level not loaded")
		return null
	return level_loaded[0].get_tilemap()

func spawn_entity(scene: String, informations: Dictionary):
	var info = informations
	var entity_spawner = get_node_or_null("/root/Multiplayer/Entities")
	if !entity_spawner:
		return null
	info.merge({"scene": scene})
	entity_spawner.show_or_spawn(scene, info)

func spawn_character(scene, info):
	var spawner = get_node_or_null("/root/Multiplayer/"+str(info["controlled_by"]))
	if !spawner:
		return
	info.merge({"scene": scene})
	spawner.spawner.spawn(info)

func get_player_color(player_id):
	if player_id != 0 and player_id in Players.keys():
		return Players[player_id]["color"]
	return Color.GRAY

func get_player(player_id):
	return get_node_or_null("/root/Multiplayer/Network/"+str(player_id))
