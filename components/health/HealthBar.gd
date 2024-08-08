extends TextureProgressBar

@export var unit: HealthComponent

func _ready():
	value = int(unit.health * 100 / unit.max_health)
	unit.healthChanged.connect(update)

func update():
	value = int(unit.health * 100 / unit.max_health)
