extends Node2D
class_name NavigationComponent

@export var network_component: NetworkComponent

@export var body: CharacterBody2D
@export var detection_range: CollisionShape2D
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
var local_movement_group:= []
var target_entity: Node2D = null
var flocked_direction: Vector2

func set_target_entity(value: Node2D):
	target_entity = value

func switch_movement_animation(_name):
	if body.sprite.animation != _name:
		body.sprite.animation = _name

func colliders_reached_target():
	for collider in get_local_units(5):
		if is_instance_valid(collider) and movement_group.has(collider.get_instance_id()):
			if collider.movement.reached_target(10):
				stop()
				reset_state()
				return

func reached_target(distance: int = 5, _target_position=self.target_position) -> bool:
	return body.position.distance_to(_target_position) < distance

func append_navigation(pos: Vector2, group, _path: Array) -> void:
	set_target_position(pos)
	set_movement_group(group)
	set_path(path + _path.slice(1), current_path_position)

func command_navigation(pos: Vector2, group, _path: Array) -> void:
	set_target_position(pos)
	set_movement_group(group)
	set_path(_path, 0)

func set_target_position(pos: Vector2):
	target_position = pos

func set_movement_group(group):
	movement_group = group

func set_path(_path, index):
	path = _path
	current_path_position = 0
	if path.size() - 1 > index:
		current_path_position = index

func get_local_units(max_neighbours: int):
	return local_movement_group.slice(0, max_neighbours)

func stop():
	target_position = body.position
	switch_movement_animation("Idle")
	
func reset_state():
	clear_navigation_command()
	target_entity = null

func get_path_point(point: Vector2, offset: int):
	if not path:
		return Vector2(0, 0)
	var lowest_distance = path[0].distance_to(point)
	var lowest_index = 0
	var index = 0
	for p in path:
		var distance = p.distance_to(point)
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
		if unit == self.body:
			continue
		cohesion += unit.position
		alignment += unit.movement.current_direction
		var distance = body.position.distance_to(unit.position)
		if distance < max_separation_distance:
			separation -= (unit.position - body.position).normalized() * (max_separation_distance / distance * speed)
	cohesion /= group.size()
	alignment /= group.size()
	var center_direction = body.position.direction_to(cohesion)
	var center_speed = speed * body.position.distance_to(cohesion) / detection_range.shape.radius
	cohesion = center_direction * center_speed
	return (separation * separation_weight) + (cohesion * cohesion_weight) + (alignment * alignment_weight)

func move_toward_target(delta):
	switch_movement_animation("Walking")
	var group = get_local_units(5)
	if reached_target(50, path[current_path_position]):
		current_path_position = get_path_point(path[current_path_position], 1)
	var next_path = path[current_path_position]
	var direction = (next_path - body.position)
	current_direction = direction
	if !flocked_direction or Engine.get_process_frames() % 10 == 0:
		flocked_direction = flock_direction(group, direction)
	body.velocity = (direction + flocked_direction).normalized() * speed
	if direction.x > 0:
		body.sprite.flip_h = false
	else:
		body.sprite.flip_h = true
	body.move_and_collide(body.velocity * delta)
	
	if !target_entity:
		if Engine.get_process_frames() % 10 == 0:
			colliders_reached_target()
	else:
		# if target in range stop
		pass

func has_move_instruction():
	return path.size() > 0
	
func clear_navigation_command():
	movement_group = {}
	path = []

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if has_move_instruction() and !reached_target():
		move_toward_target(delta)
	#elif body.attack.has_target():
		#var pos = body.attack.get_target().global_position
		#command_navigation(pos, movement_group, [body.position, pos])
	else:
		stop()
		reset_state()

func _on_local_group_body_entered(_body):
	if _body == body:
		return
	if local_movement_group.size() >= 10:
		return
	if _body.is_in_group("rts_unit") and (movement_group.has(_body.get_instance_id()) or body.attack.has_target()):
		local_movement_group.append(_body)

func _on_local_group_body_exited(_body):
	if local_movement_group.size() <= 0:
		return
	if _body.is_in_group("rts_unit"):
		local_movement_group.erase(_body)
