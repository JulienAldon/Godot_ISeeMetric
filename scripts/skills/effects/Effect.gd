extends Node2D

class_name Effect

#@export var _name: String
#@export var _description: String
@export var icon: ImageTexture
@export var duration: float
var timer: Timer
var character: CharacterBody2D

var expired = false

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(on_effect_expired)
	timer.wait_time = duration

func start(_character):
	timer.start()
	character = _character

func update(_delta):
	pass

func stop():
	pass

func on_effect_expired():
	expired = true
