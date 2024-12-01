extends Node

class_name EffectTooltip

@export var title: Label
@export var description: Label
@export var duration: Label

func set_tooltip_information(effect: Effect):
	print(effect.title)
	title.text = effect.title
	description.text = effect.description
	duration.text = str(effect.duration) + " s."
	
