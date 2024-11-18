extends ResourceEntity

class_name TreeResource

@export var network: NetworkComponent

func dispawn():
	GameManager.get_level_tilemap().bake_navigation()
	super()
