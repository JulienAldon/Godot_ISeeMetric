extends Control

@export var address = '127.0.0.1'
@export var port = 8910
var peer
@export var faction_picker: OptionButton
@export var player_name_label: LineEdit
@export var host := Node2D
@export var join := Node2D
@export var start := Node2D
@export var party_panel: Control
@export var party_creation_panel: Control
@export var network_messages: MessageQueue
@export var level: Node

@export var maximum_players: int = 4
@export var player_scene : PackedScene
@export var player_spawner : MultiplayerSpawner
@export var entity_spawner : MultiplayerSpawner

@export var faction_scenes: Dictionary
@export var king_scenes: Dictionary
@export var no_party: Label

var is_level_loaded = false

func instantiate_entity(informations: Dictionary):
	var current_entity = king_scenes[informations["type"]].instantiate()
	current_entity.controlled_by = informations["controlled_by"]
	current_entity.position = informations["position"]
	return current_entity
	#var current_entity = 

func instantiate_player(informations: Dictionary):
	var current_player = faction_scenes[informations["faction"]].instantiate()
	current_player.set_player_id(informations["id"])
	current_player.set_player_name(informations["name"])
	current_player.set_player_color(informations["color"])
	current_player.set_spawn(informations["position"])
	return current_player

func _enter_tree():
	player_spawner.spawn_function = instantiate_player
	entity_spawner.spawn_function = instantiate_entity

func _ready():
	$Message.text = ""
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
func _process(_delta):
	if is_level_loaded:
		self.hide()

# called on server and clients
func peer_connected(id):
	network_messages.add_message('Player connected ' + str(id))

# called on server and clients
func peer_disconnected(id):
	remove_player_menu(id)
	GameManager.Players.erase(id)
	disconnect_player(id)
	print('Player disconnected ' + str(id))
	network_messages.add_message('Player disconnected ' + str(id))

	
# called only on client
func connected_to_server():
	print('Successfully connected to server')
	$Message.text = "Successfully connected to server."
	send_player_information.rpc_id(1, player_name_label.text, multiplayer.get_unique_id(), GameManager.factions_attributes[faction_picker.selected].color, faction_picker.selected)

# called only on client
func connection_failed():
	print('Connection failed')
	party_panel.visible = false
	party_creation_panel.visible = true

func check_start_requirements(players):
	var can_start = false
	for child in players:
		if child.get_node('Faction').text == "":
			can_start = true
	return can_start

func add_player_menu(player):
	no_party.visible = false
	var player_menu = load('res://scenes/player_menu.tscn').instantiate()
	player_menu.get_node('Name').text = player['name']
	player_menu.get_node('Color').color = player['color']
	player_menu.get_node('Faction').text = GameManager.factions_attributes[player['faction']]["name"]
	player_menu.controller = self
	player_menu.get_node('Id').text = str(player['id'])
	$PartyPanel/Players.add_child(player_menu)
	start.disabled = check_start_requirements($PartyPanel/Players.get_children())

func update_player_menu(player):
	var player_menu = $PartyPanel/Players.get_children().filter(func(x): return x.get_node('Id').text == str(player['id']))
	if len(player_menu) > 0:
		player_menu[0].get_node('Color').color = player['color']
		player_menu[0].get_node('Faction').text = GameManager.factions_attributes[player['faction']]["name"]
	start.disabled = check_start_requirements($PartyPanel/Players.get_children())
	
func remove_player_menu(id):
	var player_menu = $PartyPanel/Players.get_children().filter(func(x): return x.get_node('Id').text == str(id))
	if len(player_menu) > 0:
		$PartyPanel/Players.remove_child(player_menu[0])
	if len($PartyPanel/Players.get_children()) <= 0:
		no_party.visible = true

func clear_menu():
	for i in GameManager.Players:
		remove_player_menu(GameManager.Players[i].id)

func clear_connection():
	clear_menu()
	stop_game()
	GameManager.Players = {}
	if peer:
		peer.close()
		peer = OfflineMultiplayerPeer.new()
	party_panel.visible = false
	party_creation_panel.visible = true
	start.disabled = true
	faction_picker.selected = -1

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
		add_player_menu(player)
	if GameManager.Players[id].color != color or GameManager.Players[id].faction != faction:
		GameManager.Players[id] = player
		update_player_menu(player)
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i]["name"], i, GameManager.Players[i]["color"], GameManager.Players[i]["faction"])

func spawn_king_packs(locations_node, king_units, king_id):
	var locations = locations_node.get_children()
	for location in locations:
		var number_spawn = randi_range(20,30)
		var loc_pos = location.position
		var location_shape = location.shape.radius
		for _i in number_spawn:
			var pos = Vector2(
				randf_range(loc_pos.x - location_shape, loc_pos.x + location_shape), 
				randf_range(loc_pos.y - location_shape, loc_pos.y + location_shape)
			)
			entity_spawner.spawn({
				"position": pos, 
				"controlled_by": king_id, 
				"type": king_units[randi_range(0, king_units.size() - 1)]
			})
	
func spawn_initial_king(_level):
	var locations = _level.king_spawns
	var king_ids = []
	for i in GameManager.Players:
		if GameManager.Players[i].faction == GameManager.Factions.King:
			king_ids.append(i)

	if king_ids.size() > 0:
		# find number of kings
		# divide locations by king number
		spawn_king_packs(locations, _level.king_initial_units, king_ids[0])

func spawn_players(locations):
	var spawn_index: int = 0
	for i in GameManager.Players:
		var player_info = {"position": locations[spawn_index].position}
		player_info.merge(GameManager.Players[i])
		player_spawner.spawn(player_info)
		spawn_index += 1

func start_game():
	var scene = load('res://scenes/game.tscn')
	# TODO: If not server cannot start game
	if multiplayer.is_server():
		change_level.call_deferred(scene)
	else:
		$Message.text = "You are not the host of the party."

func change_level(scene: PackedScene):
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	var instantiated_scene = scene.instantiate()
	level.add_child(instantiated_scene)
	spawn_players(instantiated_scene.spawns.get_children())
	spawn_initial_king(instantiated_scene)
	is_level_loaded = true

func stop_game():
	var current_level = get_tree().root.get_node_or_null("game")
	if current_level:
		is_level_loaded = false
		current_level.queue_free()
		self.show()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, maximum_players)
	if error != OK:
		$Message.text = "Already in a party."
		print('cannot host: ', error)
		peer = null
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players")
	party_panel.visible = true
	party_creation_panel.visible = false
	send_player_information(player_name_label.text, multiplayer.get_unique_id(), GameManager.factions_attributes[faction_picker.selected].color, faction_picker.selected)

func _on_join_button_down():
	if peer is ENetMultiplayerPeer:
		print("Already in a party.")
		$Message.text = "Already in a party."
		return
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	party_creation_panel.visible = false	
	party_panel.visible = true
	
func _on_start_button_down():
	start_game()

func _on_level_child_entered_tree(_node):
	is_level_loaded = true

func _on_level_child_exiting_tree(_node):
	is_level_loaded = false

func _on_faction_picker_item_selected(index):
	if multiplayer.is_server():
		send_player_information(player_name_label.text, multiplayer.get_unique_id(), GameManager.factions_attributes[index].color, index)
	else:
		send_player_information.rpc_id(1, player_name_label.text, multiplayer.get_unique_id(), GameManager.factions_attributes[index].color, index)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		clear_connection()
		get_tree().quit() # default behavior
