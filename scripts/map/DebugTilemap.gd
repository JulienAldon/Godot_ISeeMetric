extends Node2D

# Called when the node enters the scene tree for the first time.
var path = []

func _draw():
	pass
	#for a in path:
		#for p in a:
			#draw_circle(to_local(p), 5, Color.YELLOW)
		
	#if tilemap.debug_portal.size() > 0:
		#for portals in tilemap.debug_portal:
			#for portal in portals:
				#for p in portal:
					#draw_circle(tilemap.map_to_local(p.position), 5, Color.YELLOW)
					##var text = "(" + str(p.position.x) + " " + str(p.position.y) + ")"
					##draw_string(font,tilemap.map_to_local(p.position), text, 0, 50, 15, Color.BLACK)
	#if tilemap.navigation_sectors:
		#for sector in tilemap.navigation_sectors:
			#for portal in sector.portals:
				#draw_circle(tilemap.map_to_local(portal.position), 5, Color.RED)
				#var text = "(" + str(portal.position.x) + " " + str(portal.position.y) + ")"
				#draw_string(font,tilemap.map_to_local(portal.position), text, 0, 50, 15, Color.BLACK)
