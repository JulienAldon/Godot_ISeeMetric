extends Node2D

class_name BuildMode

var is_build_mode_enabled: bool = false

signal PositionConfirmed

func show_build_mode():
	is_build_mode_enabled = true

func hide_build_mode():
	is_build_mode_enabled = false

func reset_build_state():
	pass
