extends PlayerUi

@export var nb_buildings: Label
	
func set_building_count(building_nb:int, max_building: int):
	nb_buildings.text = str(building_nb) + "/" + str(max_building)
