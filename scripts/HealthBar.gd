extends TextureProgressBar

@export var unit: CharacterBody2D

func _ready():
	value = unit.health * 100 / unit.max_health
	unit.healthChanged.connect(update)

func update():
	value = unit.health * 100 / unit.max_health
