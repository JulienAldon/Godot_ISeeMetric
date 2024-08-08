extends Node2D
class_name MovementComponent

@export var acceleration := 10
@export var speed := 100
@export var body: CharacterBody2D
var input_axis: Vector2 = Vector2(0,0)
var motion: Vector2

func switch_movement_animation(_name):
	if body.sprite.animation != _name:
		body.sprite.animation = _name

func set_input_axis(_input_axis):
	input_axis = _input_axis

func _physics_process(_delta):
	if !is_multiplayer_authority():
		return
	input_axis = input_axis.normalized()
	
	body.velocity.x = move_toward(body.velocity.x, speed * input_axis.x, acceleration)
	body.velocity.y = move_toward(body.velocity.y, speed * input_axis.y, acceleration)

	if input_axis.x > 0: 
		body.sprite.flip_h = false
	elif input_axis.x < 0:
		body.sprite.flip_h = true
	if input_axis:
		switch_movement_animation("Walking")
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, speed)
		switch_movement_animation("Idle")
	
	body.move_and_slide()
