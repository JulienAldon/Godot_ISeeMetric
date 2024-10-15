extends Node2D

signal fow_updated

@export var camera: Camera2D
@export var viewport: SubViewport
@export var sprite: Sprite2D
@export var timer: Timer
var units: Array[Node2D]

var fow_stored : Array
var main_image : Image
var main_texture : ImageTexture
var viewport_texture : ImageTexture
var dissolve_test_image = preload("res://assets/Light.png")
var map_rect : Rect2

var units_data : Dictionary = {}

#func _ready():
	#sprite.centered = false
	#var map = GameManager.get_level_tilemap().get_used_rect()
	#new_fog_of_war(Rect2(0, 0, map.size.x, map.size.y))

func new_fog_of_war(new_map_rect: Rect2):
	map_rect = new_map_rect
	
	viewport.size = map_rect.size
	(viewport.get_parent() as SubViewportContainer).size = map_rect.size
	camera.position = Vector2.ZERO + map_rect.size * 0.5
	
	main_image = Image.create(
		int(map_rect.size.x),
		int(map_rect.size.y),
		false,
		Image.FORMAT_RGBA8
	)
	main_image.fill(Color(0.0, 0.0, 0.0, 1.0))
	update_texture()

#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		#var pos = get_global_mouse_position()
		#fog_of_war_dissolve(pos, dissolve_test_image.get_image())

func update_texture():
	main_texture = ImageTexture.create_from_image(main_image)
	sprite.set_texture(main_texture)

func fog_of_war_dissolve(pos: Vector2, dissolve_image: Image):
	var dissolve_image_used_rect: Rect2 = dissolve_image.get_used_rect()
	pos -= dissolve_image_used_rect.size * 0.5
	#var map_pos = map_rect.position + pos
	main_image.blend_rect(dissolve_image, dissolve_image_used_rect, pos)
	update_texture()

#func fog_of_war_units_data_process():
	#for unit_id in units_data.keys():
		#var data: Array = units_data[unit_id] as Array
		#
		#var poition_to_
