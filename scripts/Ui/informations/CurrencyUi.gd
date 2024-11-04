extends Control

class_name CurrencyUi

@export_category("Configuration")
@export var icon: Texture2D
@export var currency_type: GameManager.CurrencyType
	
@export_category("Intern")
@export var status_indicators: Dictionary
@export var icon_texture: TextureRect
@export var currency_label: Label
@export var status_indicator: TextureRect

func _ready():
	icon_texture.texture = icon

func get_currency_type() -> GameManager.CurrencyType:
	return currency_type

func set_currency(amount: int):
	currency_label.text = str(amount)

func set_status_indicator(value: int):
	if not status_indicators.has(value):
		return
	status_indicator.texture = status_indicators[value]
