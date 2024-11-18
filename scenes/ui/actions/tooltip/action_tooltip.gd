extends Node

class_name ActionTooltip

@export var title: Label
@export var description: Label
@export var currencies_ui: Array[CurrencyUi]

func set_tooltip_information(action: Action):
	title.text = action.title
	description.text = action.description
	var cost_index = 0
	for currency_ui in currencies_ui:
		if action.cost.size() > cost_index:
			currency_ui.show()
			currency_ui.set_currency(action.cost[cost_index].value)
			currency_ui.set_icon(action.cost[cost_index].icon)
			currency_ui.set_currency_type(action.cost[cost_index].type)
		else:
			currency_ui.hide()
		cost_index += 1
	
