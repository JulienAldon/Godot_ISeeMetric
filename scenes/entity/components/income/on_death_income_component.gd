extends IncomeComponent

class_name OnDeathIncomeComponent

@export var animation: AnimationPlayer
@export var yield_label: Label
@export var yield_icon: TextureRect

func yield_income(attacker_id: int):
	if multiplayer.get_unique_id() == attacker_id:
		animation.play("yield_currency")
		yield_label.text = str(income.value)
		yield_icon.texture = income.icon
		GameManager.get_player(attacker_id).earn_currency.rpc(income.value, income.type)
