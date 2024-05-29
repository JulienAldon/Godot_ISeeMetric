extends HBoxContainer

var controller: Control

func _ready():
	var current_id = multiplayer.get_unique_id()
	if current_id == $Id.text.to_int():
		$Name.modulate = Color(0, 1, 0.3, 1)

func _on_delete_button_down():
#	var current_id = multiplayer.get_unique_id()
	var player_id = $Id.text
	controller.disconnect_player(player_id.to_int())
