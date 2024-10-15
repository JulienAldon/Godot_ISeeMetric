extends Control

@export var icon: TextureRect
@export var nb: Label
var entity: Entity
var number: int = -1
var original_border_color: Color

func _ready():
	pass
	#original_border_color = border_color

func set_source(_entity, _number: int = -1):
	entity = _entity
	number = _number
	icon.texture = entity.icon


func calculate_color(value):
	if value > 80:
		return Color.WEB_GREEN
	elif value > 50:
		return Color.YELLOW
	elif value > 30:
		return Color.ORANGE
	return Color.DARK_RED

func _process(_delta):
	if entity and is_instance_valid(entity):
		#icon.texture = entity.icon
		#if "health" in entity:
			#theme.border_color = calculate_color(entity.health.health)
		#else:
			#theme.border_color = original_border_color
		if entity.controlled_by != 0:
			tooltip_text = GameManager.Players[entity.controlled_by]["name"]
		nb.text = str(number) if number != -1 else ""
		nb.visible = nb.text != ""
