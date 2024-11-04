extends PanelContainer

class_name CurrencyPanel
# internal state to set status indicator
@export var currency_container: Control
var currencies_ui: Array

func _ready():
	currencies_ui = currency_container.get_children()


func update_currencies(currencies: Dictionary):
	for currency_ui in currencies_ui:
		var currency_type: GameManager.CurrencyType = currency_ui.get_currency_type()
		if currencies.has(currency_type):
			currency_ui.set_currency(currencies[currency_type])
		else:
			currency_ui.set_currency(0)
