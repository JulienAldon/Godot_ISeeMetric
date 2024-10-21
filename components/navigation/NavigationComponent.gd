extends Node2D
class_name NavigationComponent

@export var network_component: NetworkComponent

@export var body: CharacterBody2D
@export var detection_range: int
@export var sprite: AnimatedSprite2D
@export var max_separation_distance: int = 40
@export var speed: int = 70
@export var cohesion_weight: float = 0.01
@export var separation_weight: float = 0.02
@export var alignment_weight: float = 0.5
@export var target_position: Vector2
@export var path: Array = []
var current_direction: Vector2 = Vector2(0, 0)
var movement_group: Dictionary = {}
var current_path_position: int = 0
var local_units: Array = []

var flocked_direction: Vector2

func colliders_reached_target():
	for collider in local_units:
		if is_instance_valid(collider) and movement_group.has(collider.get_instance_id()):
			if collider.movement.has_method("reached_target") and collider.movement.reached_target(30):
				stop()
				reset_state()
				return
	#if reached_target(30):
		#stop()
		#reset_state()

func reached_target(distance: int = 5, _target_position=self.target_position) -> bool:
	return body.position.distance_squared_to(_target_position) < distance * 10

func set_target_position(pos: Vector2):
	target_position = pos

func set_movement_group(group):
	movement_group = group
	#local_units = get_local_units(10)

func set_path(_path, index):
	path = _path
	current_path_position = 0
	if path.size() - 1 > index:
		current_path_position = index

func get_local_units(max_neighbours: int):
	var result = []
	var threshold = 150
	for unit in movement_group.values():
		if not is_instance_valid(unit):
			continue
		if result.size() >= max_neighbours:
			return result
		if body.position.distance_squared_to(unit.position) < threshold:
			result.append(unit)
	return result
	#return local_movement_group.slice(0, max_neighbours)

func stop():
	target_position = body.position
	body.animation.set_is_idle()
	body.attack.reset_target()
	
func reset_state():
	clear_navigation_command()

func get_path_point(point: Vector2, offset: int) -> int:
	if not path:
		return -1
	var lowest_distance = path[0].distance_squared_to(point)
	var lowest_index = 0
	var index = 0
	for p in path:
		var distance = p.distance_squared_to(point)
		if distance < lowest_distance:
			lowest_distance = distance
			lowest_index = index
		index+=1
	if path.size() - 1 < lowest_index + offset:
		return lowest_index
	return lowest_index + offset

func flock_direction(group, direction):
	if group.size() <= 1:
		return Vector2(0, 0)
	var separation = Vector2(0,0)
	var cohesion = Vector2(0,0)
	var alignment = direction
	for unit in group:
		if unit == self.body or not "current_direction" in unit.movement:
			continue
		cohesion += unit.position
		alignment += unit.movement.current_direction
		var distance = body.position.distance_squared_to(unit.position)
		if distance <= max_separation_distance:
			separation += (body.position - unit.position).normalized()
	cohesion /= group.size()
	alignment /= group.size()
	var center_direction = body.position.direction_to(cohesion)
	#var center_speed = speed * body.position.distance_to(cohesion) / detection_range
	cohesion = center_direction
	return (separation * separation_weight) + (center_direction * cohesion_weight) + (alignment * alignment_weight)

func move_toward_target(delta):
	if path.size() - 1 < current_path_position:
		return
	if !local_units or Engine.get_process_frames() % 4 == 0:
		local_units = get_local_units(5)
	var group = local_units
	if reached_target(70, path[current_path_position]):
		current_path_position = get_path_point(path[current_path_position], 1)
		if current_path_position == -1:
			return
	var next_path = path[current_path_position]
	var direction = (next_path - body.position).normalized()
	current_direction = direction
	#if !flocked_direction or Engine.get_process_frames() % 10 == 0:
	flocked_direction = flock_direction(group, direction)
	body.velocity = (direction + flocked_direction).normalized() * speed
	#body.velocity = (direction).normalized() * speed
	body.move_and_collide(body.velocity * delta)
	#if !local_units or Engine.get_process_frames() % 20 == 0:
	colliders_reached_target()

func has_move_instruction():
	return path.size() > 0
	
func clear_navigation_command():
	path = []
