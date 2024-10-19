extends Node2D

class_name MultiplayerController

@export var address = '127.0.0.1'
@export var port = 8910
var peer

@export var level_container: Node
@export var maximum_players: int = 4

@export var entities : Node2D
@export var player_spawner : MultiplayerSpawner
@export var entity_spawner : MultiplayerSpawner
@export var faction_scenes: Dictionary

@export var multiplayer_menu: MultiplayerMenu
@export var unit_spawner_scene: String
@export var level_scene: String

var is_level_loaded = false

func instantiate_entity(informations: Dictionary):
	var current_entity = load(informations['scene']).instantiate()
	for key in informations.keys():
		current_entity[key] = informations[key]
	return current_entity

func instantiate_player(informations: Dictionary):
	var current_player = faction_scenes[informations["faction"]].instantiate()
	var player_ui = load(current_player.ui_scene).instantiate()
	player_ui.minimap.player = current_player
	current_player.set_player_ui(player_ui)
	current_player.set_player_id(informations["id"])
	current_player.set_player_name(informations["name"])
	current_player.set_player_color(informations["color"])
	current_player.set_spawn(informations["position"])
	var unit = load(unit_spawner_scene).instantiate()
	unit.name = str(informations["id"])
	add_child(player_ui)
	add_child(unit, true)
	return current_player

func _enter_tree():
	player_spawner.spawn_function = instantiate_player
	entity_spawner.spawn_function = instantiate_entity

func _ready():
	multiplayer_menu.set_message("")
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
func _process(_delta):
	if is_level_loaded:
		multiplayer_menu.hide()

# called on server and clients
func peer_connected(id):
	multiplayer_menu.network_messages.add_message('Player connected ' + str(id))

# called on server and clients
func peer_disconnected(id):
	multiplayer_menu.remove_player_menu(id)
	GameManager.Players.erase(id)
	disconnect_player(id)
	print('Player disconnected ' + str(id))
	multiplayer_menu.network_messages.add_message('Player disconnected ' + str(id))

# called only on client
func connected_to_server():
	print('Successfully connected to server')
	multiplayer_menu.set_message("Successfully connected to server.")
	var selected_faction_index: int = multiplayer_menu.get_player_faction()
	send_player_information.rpc_id(1, multiplayer_menu.get_player_name(), multiplayer.get_unique_id(), GameManager.factions_attributes[selected_faction_index].color[0], selected_faction_index)

# called only on client
func connection_failed():
	print('Connection failed')
	multiplayer_menu.hide_party_panel()

func clear_menu():
	for i in GameManager.Players:
		multiplayer_menu.remove_player_menu(GameManager.Players[i].id)

func clear_connection():
	clear_menu()
	stop_game()
	GameManager.Players = {}
	await get_tree().create_timer(0.5).timeout	
	if peer:
		peer.close()
		peer = OfflineMultiplayerPeer.new()
	multiplayer_menu.hide_party_panel()

func disconnect_player(id):
	var player_id = multiplayer.multiplayer_peer.get_unique_id()
	if player_id == id or multiplayer.is_server():
		kick_player.rpc(id)
	if multiplayer.is_server() and id == 1:
		await get_tree().create_timer(0.5).timeout 
		clear_connection()
	elif id == 1:
		clear_connection()

@rpc("any_peer", "call_local")
func kick_player(id):
	if not GameManager.Players.has(id):
		return
	if multiplayer.is_server():
		if id == 1:
			for i in GameManager.Players:
				if i != 1:
					kick_player.rpc(i)
	else:
		clear_connection()

@rpc("any_peer")
func send_player_information(_name, id, color, faction):
	var player = {
		'faction': faction,
		'name': _name,
		'id': id,
		'color': color
	}
	if !GameManager.Players.has(id):
		GameManager.Players[id] = player
		if is_level_loaded:
			var player_info = {"position": Vector2(0, 0)}
			player_info.merge(player)
			player_spawner.spawn(player_info)
		multiplayer_menu.add_player_menu(player)
	if GameManager.Players[id].color != color or GameManager.Players[id].faction != faction:
		GameManager.Players[id] = player
		multiplayer_menu.update_player_menu(player)
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i]["name"], i, GameManager.Players[i]["color"], GameManager.Players[i]["faction"])

func spawn_players(locations):
	var spawn_index: int = 0
	for i in GameManager.Players:
		var player_info = {"position": locations[spawn_index].global_position}
		var outpost = locations[spawn_index].get_node(locations[spawn_index].get_meta("start_outpost"))
		outpost.capture.capture_success(GameManager.Players[i]["id"])
		player_info.merge(GameManager.Players[i])
		player_spawner.spawn(player_info)
		spawn_index += 1

func start_game():
	var scene = load(level_scene)
	# TODO: If not server cannot start game
	if multiplayer.is_server():
		change_level(scene)
	else:
		multiplayer_menu.set_message("You are not the host of the party.")

func change_level(scene: PackedScene):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
	var instantiated_scene = scene.instantiate()
	level_container.add_child(instantiated_scene)
	spawn_players(instantiated_scene.spawns.get_children())
	is_level_loaded = true

func stop_game():
	if level_container.get_children().size() > 0:
		var multi = self
		var node = multi.get_node(str(multiplayer.get_unique_id()))
		node.call_deferred("queue_free")
		if multiplayer.is_server():
			for child in entities.get_children():
				child.call_deferred("queue_free")
			entities.call_deferred("queue_free")
		is_level_loaded = false
		level_container.call_deferred("queue_free")
		multiplayer_menu.show()

func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, maximum_players)
	if error != OK:
		multiplayer_menu.set_message("Already in a party.")
		print('cannot host: ', error)
		peer = null
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players")
	multiplayer_menu.show_party_panel()
	var selected_faction_index: int = multiplayer_menu.get_player_faction()
	send_player_information(multiplayer_menu.get_player_name(), multiplayer.get_unique_id(), GameManager.factions_attributes[selected_faction_index].color[0], selected_faction_index)

func join_game():
	if peer is ENetMultiplayerPeer:
		print("Already in a party.")
		multiplayer_menu.set_message("Already in a party.")
		return
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	multiplayer_menu.show_party_panel()

func _on_level_child_entered_tree(_node):
	is_level_loaded = true

func _on_level_child_exiting_tree(_node):
	is_level_loaded = false

func pick_faction(index):
	var color_index = 0
	var used_colors = GameManager.Players.values().filter(func(el): return el.faction == index)
	color_index += used_colors.size()
	if multiplayer.is_server():
		send_player_information(multiplayer_menu.get_player_name(), multiplayer.get_unique_id(), GameManager.factions_attributes[index].color[color_index], index)
	else:
		send_player_information.rpc_id(1, multiplayer_menu.get_player_name(), multiplayer.get_unique_id(), GameManager.factions_attributes[index].color[color_index], index)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		clear_connection()
		get_tree().quit() # default behavior
