extends PanelContainer

var outpost: Outpost

@export var player: PlayerController

@export var income_label: Label
@export var total_income_label: Label
@export var controlled_by_label: Label

@export var action_panel: VBoxContainer
@export var action_container: GridContainer
@export var action_queue_container: HBoxContainer

@export var player_actions: Node2D

var possible_actions: Array[Node]

var action_queue: Array[Node]

var currency_text = {
	GameManager.CurrencyType.Gold: "Gold",
	GameManager.CurrencyType.Faith: "Faith",
	GameManager.CurrencyType.Materials: "Materials",
}

func assign_outpost_informations():
	controlled_by_label.text = GameManager.Players[outpost.controlled_by].name
	income_label.text = str(outpost.income) + " " + currency_text[outpost.currency_type] + "/s"
	total_income_label.text = str(outpost.total_income) + " " + currency_text[outpost.currency_type]
	action_panel.visible = multiplayer.get_unique_id() == outpost.controlled_by
	if action_panel.visible == true:
		var index = 0
		var actions_buttons = action_container.get_children()
		for action in possible_actions:
			actions_buttons[index].set_action_icon(action)
			index += 1

func _ready():
	possible_actions = player_actions.get_children()
	action_queue = action_queue_container.get_children()
	for action in action_container.get_children():
		action.ActionButtonPressed.connect(trigger_action)

func trigger_action(action: Action):
	if action is Build:
		outpost.set_action_build_mode(action)
		return
	outpost.action_controller.queue_action(action, outpost.position + Vector2(0, 30))
	set_action_queue_icons()

func set_informations_and_show(_outpost):
	outpost = _outpost
	assign_outpost_informations()
	self.visible = true

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			self.visible = false

func _process(_delta):
	if outpost and outpost != null:
		if outpost.position.distance_to(player.position + player.camera.position + player.center_offset) > 1000:
			self.visible = false
		set_action_queue_visible()

func set_action_queue_icons():
	var index = 0
	for _action in outpost.action_controller.action_queue:
		action_queue[index].texture = _action.icon
		action_queue[index].visible = true
		index += 1

func set_action_queue_visible():
	var index = 0
	for ui_action in action_queue:
		if outpost.action_controller.action_queue.size() > index:
			ui_action.visible = true
		else:
			ui_action.visible = false
		index += 1
