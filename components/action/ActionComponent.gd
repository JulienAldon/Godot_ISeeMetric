extends Node2D

class_name ActionComponent

@export var body: Node2D

@export var actions_container: Node2D
@export var max_queue_size: int = 5

var current_action: Action
var current_pos: Vector2
var can_trigger_action: bool = true
var action_queue: Array[Action] = []
var action_position: Array[Vector2] = []

func get_possible_actions() -> Array:
	var actions = GameManager.get_player(body.controlled_by).get_outpost_actions()
	if actions and body is Outpost:
		return actions.get_children()
	return actions_container.get_children()

func get_action_queue() -> Array[Action]:
	return action_queue

func get_current_action() -> Action:
	return current_action

func start_action():
	current_action = action_queue[0]
	current_pos = action_position[0]
	current_action.ActionFinished.connect(finish_action)
	current_action.start(current_pos, multiplayer.get_unique_id())
	can_trigger_action = false

func can_queue_action():
	return action_queue.size() < max_queue_size

func queue_action(action: Action, pos: Vector2):
	if can_queue_action():
		action_queue.append(action)
		action_position.append(pos)

func finish_action():
	can_trigger_action = true
	current_action.ActionFinished.disconnect(finish_action)
	dequeue_action()

func dequeue_action():
	action_queue.pop_front()
	action_position.pop_front()

func _process(_delta):
	if action_queue.size() > 0 and can_trigger_action:
		start_action()
