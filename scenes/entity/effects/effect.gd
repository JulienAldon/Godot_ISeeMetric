extends Node2D

class_name Effect

#@export var _name: String
#@export var _description: String
@export var effect_id: String
@export var icon: Texture2D
@export var duration: float
@export var title: String
@export var description: String
var timer: Timer
var character: Entity

var expired = false

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(on_effect_expired)
	if duration != 0:
		timer.wait_time = duration

func start(_character):
	if duration != 0:
		timer.start()
	character = _character

func update(_delta):
	pass

func stop():
	pass

func on_effect_expired():
	expired = true
