extends Node2D

class_name RallyPointComponent

@export var is_enabled: bool = true

var current_path_position: int = 0
var path: Array
@onready var target_position: Vector2 = self.global_position
