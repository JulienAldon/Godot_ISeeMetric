extends Node2D

@export var tilemap: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	if tilemap.navigation_sectors_portals:
		for sector in tilemap.navigation_sectors_portals:
			for portal in sector:
				draw_circle(tilemap.map_to_local(portal), 5, Color.RED)
	if tilemap.sectors_portals_tile:
		for sector in tilemap.sectors_portals_tile:
			for portal in sector:
				for tile in portal:
					draw_circle(tilemap.map_to_local(tile), 3, Color.BLUE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
