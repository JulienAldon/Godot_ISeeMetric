extends Control

class_name MultiplayerMenu

@export var controller: MultiplayerController
@export var player_menu_scene: PackedScene

@export var faction_picker: OptionButton
@export var player_name_label: LineEdit
@export var host := Button
@export var join := Button
@export var start := Button
@export var party_panel: Control
@export var party_players_container: Control
@export var party_creation_panel: Control
@export var network_messages: MessageQueue
@export var no_party: Label
@export var message: Label

func _ready() -> void:
	host.button_down.connect(_on_host_button_down)
	join.button_down.connect(_on_join_button_down)
	start.button_down.connect(_on_start_button_down)

func set_message(value):
	message.text = value

func get_player_faction():
	return faction_picker.selected

func get_player_name():
	return player_name_label.text

func show_party_panel():
	party_panel.visible = true
	party_creation_panel.visible = false
	
func hide_party_panel():
	party_panel.visible = false
	party_creation_panel.visible = true
	start.disabled = true
	faction_picker.selected = -1
	
func add_player_menu(player):
	no_party.visible = false
	var player_menu = player_menu_scene.instantiate()
	player_menu.get_node('Name').text = player['name']
	player_menu.get_node('Color').color = player['color']
	player_menu.get_node('Faction').text = GameManager.factions_attributes[player['faction']]["name"]
	player_menu.get_node('Id').text = str(player['id'])
	player_menu.PlayerRemoved.connect(controller.disconnect_player)
	party_players_container.add_child(player_menu)
	start.disabled = check_start_requirements(party_players_container.get_children())

func update_player_menu(player):
	var player_menu = party_players_container.get_children().filter(func(x): return x.get_node('Id').text == str(player['id']))
	if len(player_menu) > 0:
		player_menu[0].get_node('Color').color = player['color']
		player_menu[0].get_node('Faction').text = GameManager.factions_attributes[player['faction']]["name"]
	start.disabled = check_start_requirements(party_players_container.get_children())
	
func remove_player_menu(id):
	var player_menu = party_players_container.get_children().filter(func(x): return x.get_node('Id').text == str(id))
	if len(player_menu) > 0:
		party_players_container.remove_child(player_menu[0])
	if len(party_players_container.get_children()) <= 0:
		no_party.visible = true

func check_start_requirements(players):
	var can_start = false
	for child in players:
		if child.get_faction() == "":
			can_start = true
	return can_start

func _on_host_button_down() -> void:
	controller.host_game()

func _on_join_button_down() -> void:
	controller.join_game()

func _on_start_button_down() -> void:
	controller.start_game()

func _on_faction_picker_item_selected(index: int) -> void:
	controller.pick_faction(index)
