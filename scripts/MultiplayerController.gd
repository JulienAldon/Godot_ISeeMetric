extends Control

@export var address = '127.0.0.1'
@export var port = 8910
var peer
# Called when the node enters the scene tree for the first time.
func _ready():
	$Message.text = ""
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# called on server and clients
func peer_connected(id):
	print('Player connected ' + str(id))

# called on server and clients
func peer_disconnected(id):
	remove_player_menu(id)
	GameManager.Players.erase(id)
	print('Player disconnected ' + str(id))

# called only on client
func connected_to_server():
	print('Successfully connected to server')
	$Message.text = "Successfully connected to server."
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

# called only on client
func connection_failed():
	print('Connection failed')

func add_player_menu(player):
	var player_menu = load('res://PlayerMenu.tscn').instantiate()
	player_menu.get_node('Name').text = player['name']
	player_menu.controller = self
	player_menu.get_node('Id').text = str(player['id'])
	$PartyPanel/Players.add_child(player_menu)

func remove_player_menu(id):
	var player_menu = $PartyPanel/Players.get_children().filter(func(x): return x.get_node('Id').text == str(id))
	if len(player_menu) > 0:
		$PartyPanel/Players.remove_child(player_menu[0])

func clear_menu():
	for i in GameManager.Players:
		remove_player_menu(GameManager.Players[i].id)

func clear_connection(id):
	clear_menu()
	GameManager.Players = {}
	peer.disconnect_peer(id)
	peer.close()
	peer = null

func disconnect_player(id):
	var player_id = multiplayer.multiplayer_peer.get_unique_id()
	if player_id == id or multiplayer.is_server():
		kick_player.rpc(id)
	if multiplayer.is_server() and id == 1:
		await get_tree().create_timer(0.2).timeout 
		clear_connection(id)
	else:
		$Message.text = "You are not allowed to kick this player."

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
		clear_connection(id)
		$Message.text = "Successfully disconnected from server."

@rpc("any_peer")
func send_player_information(_name, id):
	if !GameManager.Players.has(id):
		var player = {
			'name': _name,
			'id': id
		}
		GameManager.Players[id] = player
		add_player_menu(player)
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load('res://game.tscn').instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 6)
	if error != OK:
		$Message.text = "You cannot host the game."
		print('cannot host: ', error)
		peer = null
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players")
	send_player_information($LineEdit.text, multiplayer.get_unique_id())

func _on_join_button_down():
	if peer:
		print("Already in a party.")
		$Message.text = "Already in a party."
		return
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	
func _on_start_button_down():
	start_game.rpc()
