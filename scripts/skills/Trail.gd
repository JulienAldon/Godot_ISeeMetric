extends Line2D

@export var max_points: int = 20
@onready var curve := Curve2D.new()
@export var animation_tree: AnimationTree
@export var is_start: bool = false

func _process(_delta):
	if get_parent().visible:
		show()
		curve.add_point(get_parent().global_position)
		if curve.get_baked_points().size() > max_points:
			curve.remove_point(0)
		points = curve.get_baked_points()
	else:
		stop()

func stop():
	hide()
	points.clear()
	curve.clear_points()
	is_start = false
	#var tw := get_tree().create_tween()
	#tw.tween_property(self, "modulate:a", 0.0, 1)
	#await tw.finished
