extends TextureProgressBar

@export var unit: HealthComponent


func _ready():
	value = floor(int(unit.health * 100 / unit.max_health))
	unit.HealthChanged.connect(update)
	
func update():
	value = floor(int(unit.health * 100 / unit.max_health))
