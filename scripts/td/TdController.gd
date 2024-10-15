extends Controller

class_name TdController

@export var character: TdCharacter
var input_axis = Vector2(0, 0)

@export var mouse_shape: Shape2D

func _ready():
	super()
	character.controlled_by = player_id
	player.show_entities_actions([character], player_id)

func respawn():
	character.health.reset()
	character.position = Vector2(0, 0)

func _process(_delta):
	if character.health.health <= 0:
		respawn()
	if !player_id == multiplayer.get_unique_id():
		return
	if player.get_displayed_action().size() <= 0:
		player.show_entities_actions([character], player_id)

	#if trigger_action and selected_skill:
		#trigger_skill(selected_skill)

func _physics_process(_delta):
	if player_id == multiplayer.get_unique_id():
		move_controller.move([character], input_axis)

func get_overlapping_building(pos: Vector2):
	var query = PhysicsShapeQueryParameters2D.new()
	var space = get_world_2d().direct_space_state
	query.shape = mouse_shape
	query.collision_mask = 2
	query.transform = Transform2D(0, pos)
	var result = space.intersect_shape(query)
	return result.map(func(el): return el.collider).filter(func(el): return el.controlled_by == player_id and el is Building)

func _unhandled_input(event):
	input_axis.x = Input.get_axis("Left", "Right")
	input_axis.y = Input.get_axis("Top", "Bottom")
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_MASK_RIGHT:
		var buildings = get_overlapping_building(get_global_mouse_position())
		if buildings.size() <= 0:
			return
		if "death" in buildings[0]:
			buildings[0].dispawn()
	#if Input.is_action_pressed("spell_slot_1"):
		#selected_skill = skills[0]
		#trigger_action = true
	#elif Input.is_action_pressed("spell_slot_2"):
		#selected_skill = skills[1]
		#trigger_action = true
	#elif Input.is_action_pressed("spell_slot_3"):
		#selected_skill = skills[2]
		#trigger_action = true
	#elif Input.is_action_pressed("spell_slot_4"):
		#selected_skill = skills[3]
		#trigger_action = true
	#else:
		#selected_skill = null
		#trigger_action = false
	#if (Input.is_action_just_released("spell_slot_1") or Input.is_action_just_released("spell_slot_2") or
		 #Input.is_action_just_released("spell_slot_3") or Input.is_action_just_released("spell_slot_4")):
		#selected_skill = null
		#trigger_action = false
