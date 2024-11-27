extends TextureProgressBar

@export var unit: HealthComponent
@export var secondary_bar: TextureProgressBar

func _ready():
	if secondary_bar:
		secondary_bar.value = floor(int(unit.health * 100 / unit.max_health))
	value = floor(int(unit.health * 100 / unit.max_health))
	unit.HealthChanged.connect(update)
	
func update():
	var tween = get_tree().create_tween()
	if secondary_bar:
		value = floor(int(unit.health * 100 / unit.max_health))
		#await get_tree().create_timer(0.5).timeout
		tween.tween_property(secondary_bar, "value", floor(int(unit.health * 100 / unit.max_health)), 0.5)
	else:
		tween.tween_property(self, "value", floor(int(unit.health * 100 / unit.max_health)), 0.5)
