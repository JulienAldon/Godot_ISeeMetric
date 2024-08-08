extends CharacterBody2D

@onready var sprite = $Sprite
@export var max_separation_distance = 40
@export var productions: Array[Production]

enum AnimState {
	Idle,
	Move,
	Build,
	Harvest,
	Attack
}

enum Actions {
	Idle,
	Build,
	MoveHarvest,
	Harvest,
	MoveDeposit,
	Deposit,
	Move,
}
var current_action: Actions
# Stats
@export var max_health := 50
var health := max_health
signal healthChanged
@export var speed := 1

# State
var controlled_by = 1
var selected = { 'status': false}

# Movement
var target_position = null
var path = []
var current_direction = Vector2(0, 0)
var movement_group = []
var local_units = []
@export var cohesion_weight = 0
@export var separation_weight = 0.5
@export var alignment_weight = 0.5
var current_path_position

var animation_state: AnimState = AnimState.Idle

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(controlled_by).to_int())

func set_selected(status):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		selected['status'] = status
	$HealthBar.visible = status

func set_manual_action(prod: Production):
	pass

func set_action_entity(_entity):
	pass

func set_movement_group(group):
	movement_group = group

func set_target_position(pos):
	current_action = Actions.Move
	target_position = pos

func set_path(_path):
	path = _path
	if path.size() > 0:
		current_path_position = path[0]

func colliders_reached_target():
	var group = get_local_units(5)
	for collider in group:
		for unit in movement_group:
			if unit.collider.is_in_group("unit") and unit.collider == collider and collider.target_position:
				if collider.reached_target():
					set_target_position(position)
					animation_state = AnimState.Idle

func reached_target(distance: int = 5, _target_position=self.target_position) -> bool:
	return position.distance_to(_target_position) < distance

func get_local_units(max_neighbours: int) -> Array:
	return local_units.slice(0, max_neighbours)

func get_next_path_point(point: Vector2) -> Vector2:
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
	if path.size() - 1 < lowest_index + 1:
		return path[lowest_index]
	return path[lowest_index + 1]

func flock_direction(group, direction):
	var separation = Vector2()
	var cohesion = Vector2()
	var alignment = direction

	for unit in group:
		cohesion += unit.position
		alignment += unit.current_direction
		var distance = position.distance_to(unit.position)
		if distance < max_separation_distance:
			separation -= (unit.position - position).normalized() * (max_separation_distance / distance * speed)
	if group.size() > 0:
		cohesion /= group.size()
		alignment /= group.size()
		var center_direction = position.direction_to(cohesion)
		var center_speed = speed * position.distance_to(cohesion) / $DetectionRange/CircleCollisionShape2D.shape.radius
		cohesion = center_direction * center_speed
	return (separation.normalized() * separation_weight) + (cohesion.normalized() * cohesion_weight) + (alignment * alignment_weight)

func move_toward_target(_delta):
	if !reached_target():
		animation_state = AnimState.Move
		if reached_target(10, current_path_position):
			var next_path = get_next_path_point(position)
			current_path_position = next_path
		var direction = (current_path_position - position).normalized()
		var group = get_local_units(5)
		current_direction = direction
		velocity = (direction + flock_direction(group, direction)).normalized() * speed
		$Sprite.look_at(position + direction)
		move_and_slide()
		#colliders_reached_target()

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	if path.size() > 0 and current_action != Actions.Idle:
		move_toward_target(delta)

func _process(_delta):
	if health <= 0:
		GameManager.destroy_unit.rpc(get_path())
	if selected['status'] == true:
		sprite.material.set_shader_parameter('width', 1.2)
	else:
		sprite.material.set_shader_parameter('width', 0.0)

func _on_detection_range_body_entered(body):
	if body == self:
		return
	if body.is_in_group("unit"):
		local_units.append(body)
	
func _on_detection_range_body_exited(body):
	if body.is_in_group("unit"):
		local_units.erase(body)
