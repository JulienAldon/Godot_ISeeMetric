extends IncomeComponent

class_name OnTimerIncomeComponent

@export_group("Dependencies")
@export var capture: CaptureComponent

@export_group("Intern")
@export var currency_timer: Timer

var total_income: int = 0

func _on_currency_rate_timeout():
	var controlled_by = capture.get_controlled_by()
	if controlled_by != 0:
		GameManager.get_player(controlled_by).earn_currency.rpc(income)
		total_income += income.value

func start_currency_yield():
	currency_timer.start()

func stop_currency_yield():
	currency_timer.stop()
