extends Sprite2D

class_name FogSystem

const LightTexture = preload("res://assets/Light.png")
@export var tilemap_layer: TileMapLayer
@export var fog_color: Color

const GRID_SIZE: float = 16

var fog_image = Image.new()
var fog_texture = ImageTexture.new()
var light_image = LightTexture.get_image()
var light_offset = Vector2(LightTexture.get_width()/2, LightTexture.get_height()/2)
var map_size
var map_offset: Vector2

func _ready():
	map_size = tilemap_layer.get_used_rect()
	var display_width = map_size.size.x * GRID_SIZE
	var display_height = map_size.size.y * GRID_SIZE
	map_offset = Vector2(display_width / 2, display_height / 2)
	var fog_image_width = display_width/GRID_SIZE
	var fog_image_height = display_height/GRID_SIZE
	fog_image = Image.create(fog_image_width, fog_image_height, false, Image.FORMAT_RGBAH)
	fog_image.fill(fog_color)
	light_image.convert(Image.FORMAT_RGBAH)
	scale *= GRID_SIZE
	update_fog_image_texture()

func update_fog(new_grid_position, unit_vision_range: int):
	var pos = (new_grid_position + map_offset) / GRID_SIZE
	var img = Image.new()
	img.copy_from(light_image)
	img.resize((unit_vision_range * 2)/GRID_SIZE,  (unit_vision_range * 2)/GRID_SIZE)
	light_offset = Vector2(img.get_width() / 2, img.get_height() / 2)
	var light_rect = Rect2(Vector2.ZERO, Vector2(img.get_width(), img.get_height()))
	fog_image.blend_rect(img, light_rect, pos - light_offset)
	
	update_fog_image_texture()

func update_fog_image_texture():
	fog_texture = ImageTexture.create_from_image(fog_image)
	texture = fog_texture

func is_in_range(positions, unit_pos):
	for pos in positions:
		if unit_pos.distance_to(pos) < positions[pos]:
			return true
	return false

func update_fog_units():
	fog_image.fill(fog_color)
	var group = get_tree().get_nodes_in_group("player_entity") + get_tree().get_nodes_in_group("building")
	var positions: Dictionary
	var other_authority_units = []
	for unit in group:
		if unit.controlled_by == multiplayer.get_unique_id():
			positions[unit.global_position] = unit.vision_range
			update_fog(unit.global_position, unit.vision_range)
		elif unit is not Outpost:
			other_authority_units.append(unit)
	
	for unit in other_authority_units:
		if is_in_range(positions, unit.global_position):
			unit.show()
		else:
			unit.hide()
				
	
func _process(_delta):
	update_fog_units()
