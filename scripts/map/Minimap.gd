extends Control

class_name Minimap

var player: PlayerController

@export var outpost_marker: Sprite2D
@export var unit_marker: Sprite2D
@export var entities: Node2D
@export var player_sprite: Sprite2D
@export var texture_rect: TextureRect
@onready var tilemap = GameManager.get_level_tilemap()

var map_size: Vector2
var minimap_reduction_ratio: Vector2
var is_hover: bool = false

@onready var icons = {
	"unit": unit_marker,
	"outpost": outpost_marker
}

var map_texture: ImageTexture

func create_minimap_texture():
	map_size = tilemap.get_used_rect().size
	var cells = tilemap.get_used_cells(0)
	cells.sort()
	var image: Image = Image.create(int(map_size.x), int(map_size.y), false, Image.FORMAT_RGBA8)
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			var color = Color.STEEL_BLUE
			var cell = cells[map_size.y * x + y]
			var cell_atlas_pos = tilemap.get_cell_atlas_coords(0, cell)
			if cell_atlas_pos != tilemap.boundary_block_atlas_pos:
				color = Color.WEB_GREEN
			image.set_pixel(x, y, color)
	map_texture = ImageTexture.create_from_image(image)
	texture_rect.set_texture(map_texture)

func _ready():
	create_minimap_texture()
	
	map_size = tilemap.get_used_rect().size * 16
	minimap_reduction_ratio = Vector2((map_size.x / size.x), (map_size.y / size.y))
	player_sprite.scale = Vector2(10, 10) / minimap_reduction_ratio
	
	var minimap_items = get_tree().get_nodes_in_group("minimap_item")
	for item in minimap_items:
		var marker = icons[item.minimap_icon].duplicate()
		marker.show()
		marker.position = translate_to_minimap_coords(item.position)
		marker.modulate = GameManager.get_player_color(item.controlled_by)
		entities.add_child(marker)

func translate_to_minimap_coords(pos: Vector2):
	return (pos / minimap_reduction_ratio) + (size / 2)

func translate_to_world_pos(pos: Vector2):
	return ((pos - (size / 2) ) * minimap_reduction_ratio)

func _process(_delta):
	player_sprite.position = translate_to_minimap_coords(player.camera.global_position) + Vector2((player_sprite.texture.get_size() * player_sprite.scale)/ 2)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var pos = translate_to_world_pos(event.position - Vector2((player_sprite.texture.get_size() * player_sprite.scale)/ 2))
			player.current_controller.minimap_command_position(pos)
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			var pos = translate_to_world_pos(event.position)
			player.current_controller.minimap_command_action(pos)
