extends Node2D

@export var fog: Sprite2D
@export var fog_dimensions: Vector2
@export var light_texture: CompressedTexture2D
@export var light_dimensions: Vector2

var time_since_last_fog_update = 0.0

var light_image: Image
var light_offset: Vector2
var light_rect: Rect2

var fog_texture: ImageTexture
var fog_image: Image

func init_fog():
	light_image = light_texture.get_image()
	light_image.resize(light_dimensions.x, light_dimensions.y)
	
	light_offset = Vector2(light_dimensions.x/2, light_dimensions.y/2)
	
	fog_image = Image.create(fog_dimensions.x, fog_dimensions.y, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color.BLACK)
	fog_texture = ImageTexture.create_from_image(fog_image)
	fog.texture = fog_texture
	update_fog(Vector2.ZERO)

func update_fog(pos):
	fog_image.blend_rect(light_image, light_rect, pos - light_offset)
	fog_texture.update(fog_image)

#func _process(delta):
	#time_since_last_fog_update >= debounce_time:
		#var player_input = player.
		#if player_iput.length() > 0:
			#time_since_last_fog_update = 0.0
			#update_fog(player.position)
