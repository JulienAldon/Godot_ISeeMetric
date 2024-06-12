extends CharacterBody2D

@onready var sprite = $Sprite

var tilemap

signal healthChanged
@export var max_separation_distance = 15

# Stats
@export var max_health := 50
var health := max_health
@export var speed := 300
@export var attack_cooldown := 400
var circle = CircleShape2D.new()

# State
var controlled_by = 1
var can_attack = true
var selected = { 'status': false}

# Movement
var flow_field
var movement_group
var target_position = null
var current_direction = Vector2(0, 0)
var leg_reset_threshold = 9

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(controlled_by).to_int())

func set_selected(status):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		selected['status'] = status
	$HealthBar.visible = status

func colliders_reached_target():
	for i in get_unit_neighbors(15):
		var collider = i.collider
		for unit in movement_group:
			if is_instance_valid(unit.collider):
				if unit.collider == collider:
					if collider.reached_target():
						set_target_position(position, movement_group)

func reached_target() -> bool:
	return position.distance_to(target_position) < 5

func set_target_position(pos, units):
	movement_group = units
	target_position = pos
	
func set_flow_field(field, map):
	flow_field = field
	tilemap = map
	queue_redraw()

func get_unit_neighbors(radius):
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	circle.radius = radius
	query.shape = circle
	query.collision_mask = 1
	query.transform = Transform2D(0, position)
	return space.intersect_shape(query)

func move_toward_target(_delta):
	if !reached_target():
		var current_pos = Vector2(tilemap.local_to_map(position))
		var sector_index = tilemap.find_in_navigation_sectors(current_pos)
		var tile_index = flow_field[sector_index].find_cell(current_pos)
		if tile_index == -1:
			return
		var flow_cell = flow_field[sector_index].cells[tile_index]
		#print("tile index: ", sector_index, " ", tile_index, " ", current_pos," ",  flow_cell.flow)
		var direction = cartesian_to_isometric(flow_cell.flow)
		var group = get_unit_neighbors(50)
		var separation = Vector2()
		var cohesion = Vector2()
		
		var alignment = direction
		var separation_weight = 0.8
		var cohesion_weight = 0.2
		var alignment_weight = 0.5

		for unit in group:
			cohesion += unit.collider.position
			alignment += unit.collider.current_direction
			if unit.collider != self:
				var distance = position.distance_to(unit.collider.position)
				if distance < max_separation_distance:
					separation -= (unit.collider.position - position).normalized() * (max_separation_distance / distance * speed)
		if group.size() > 0:
			cohesion /= group.size()
			alignment /= group.size()
			cohesion = position.direction_to(cohesion)
		current_direction = direction
		velocity = (direction + (separation.normalized() * separation_weight) + (cohesion * cohesion_weight) + (alignment * alignment_weight)).normalized() * speed
		move_and_slide()
		$Sprite.look_at(target_position)
		colliders_reached_target()

@rpc("any_peer", "call_local")
func hit(value):
	health -= value
	healthChanged.emit()
	return health

func filter_hostile_entity(e):
	return str(e.controlled_by).to_int() != multiplayer.get_unique_id()

func attack_nearby_target_entity():
	var entities_in_range = $AttackRange.get_overlapping_bodies()
	if len(entities_in_range) < 0:
		return
	var hostile_entities = entities_in_range.filter(filter_hostile_entity)
	if len(hostile_entities) > 0 and can_attack:
		for entity in hostile_entities:
			entity.hit.rpc(10)
		$AttackCooldown.start()
		can_attack = false

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	if flow_field:
		move_toward_target(delta)
	attack_nearby_target_entity()

func _process(_delta):
	if health <= 0:
		GameManager.destroy_unit.rpc(get_path())
	if selected['status'] == true:
		sprite.material.set_shader_parameter('width', 1.2)
	else:
		sprite.material.set_shader_parameter('width', 0.0)

func _on_attack_cooldown_timeout():
	can_attack = true
