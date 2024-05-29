extends Node2D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	for i in GameManager.Players:
		if GameManager.Players[i].id == multiplayer.get_unique_id():			
			var currentPlayer = PlayerScene.instantiate()
			currentPlayer.set_tilemap($TileMap)
			currentPlayer.set_player_id(str(GameManager.Players[i].id))
			currentPlayer.set_player_name(str(GameManager.Players[i].name))
			add_child(currentPlayer)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
