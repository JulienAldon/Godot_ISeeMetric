extends VBoxContainer
class_name MessageQueue
@export var timer: Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(remove_messages)
	
func add_message(text):
	timer.start()
	var message = Label.new()
	message.text = text
	add_child(message)

func remove_messages():
	timer.stop()
	for child in get_children():
		if child is Label:
			child.queue_free()
