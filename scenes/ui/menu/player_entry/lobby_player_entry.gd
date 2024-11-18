extends HBoxContainer

signal PlayerRemoved

func _ready():
	var current_id = multiplayer.get_unique_id()
	if current_id == $Id.text.to_int():
		$Name.modulate = Color(0, 1, 0.3, 1)

func get_faction():
	return $Faction.text

func _on_delete_button_down():
#	var current_id = multiplayer.get_unique_id()
	var player_id: String = $Id.text
	PlayerRemoved.emit(player_id.to_int())
