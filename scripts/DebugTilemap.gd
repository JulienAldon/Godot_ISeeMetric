extends Node2D

@export var tilemap: TileMap
@export var font: Font
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	if tilemap.debug_portal.size() > 0:
		for portals in tilemap.debug_portal:
			for portal in portals:
				for p in portal:
					draw_circle(tilemap.map_to_local(p.position), 5, Color.YELLOW)
					#var text = "(" + str(p.position.x) + " " + str(p.position.y) + ")"
					#draw_string(font,tilemap.map_to_local(p.position), text, 0, 50, 15, Color.BLACK)
	if tilemap.navigation_sectors:
		for sector in tilemap.navigation_sectors:
			for portal in sector.portals:
				draw_circle(tilemap.map_to_local(portal.position), 5, Color.RED)
				var text = "(" + str(portal.position.x) + " " + str(portal.position.y) + ")"
				draw_string(font,tilemap.map_to_local(portal.position), text, 0, 50, 15, Color.BLACK)
	if tilemap.debug_sector:
		for sector in tilemap.debug_sector:
			for cell in sector.cells:
				var text = str(cell.cost)
				draw_string(font,tilemap.map_to_local(cell.position), text, 0, 50, 8, Color.RED)
