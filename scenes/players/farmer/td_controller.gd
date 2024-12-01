extends Controller

class_name TdController

@export var character: TdCharacter
@export var mouse_shape: Shape2D
@export var max_buildings_per_outpost: int = 6

var input_axis = Vector2(0, 0)
var last_select: Entity

var owned_buildings: Array[TdBuilding]
var max_buildings: int

func _ready():
	super()
	max_buildings = player.get_owned_outpost().size() * max_buildings_per_outpost
	character.controlled_by = player_id
	player.show_entities_actions([character], player_id)

func add_building(building: TdBuilding):
	owned_buildings.append(building)

func remove_building(building: TdBuilding):
	owned_buildings.erase(building)

func can_queue_action(action: Action):
	var can_queue: bool = true
	if action is Build:
		can_queue = owned_buildings.size() < max_buildings
	if action is UpgradeBuilding:
		can_queue = action.building.upgrade.can_upgrade()
	return can_queue

func select_entity(entity: Entity):
	if is_instance_valid(last_select):
		last_select.action_panel.set_source([])
	if entity is TdBuilding and entity.controlled_by == player_id:
		entity.action_panel.set_source([entity])
		last_select = entity

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
	
	max_buildings = player.get_owned_outpost().size() * max_buildings_per_outpost
	player.gui.set_building_count(owned_buildings.size(), max_buildings)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if character.attack.is_attack_possible() and character.attack.is_in_range(character.global_position):
			character.attack.attack_target()
			character.animation.set_is_attack(1 / character.stats.get_attack_speed(),  character.attack.target.global_position - character.global_position, "Action")
	#if trigger_action and selected_skill:
		#trigger_skill(selected_skill)

func _physics_process(_delta):
	if character.animation.get_attack():
		move_controller.move([character], Vector2(0, 0))
		return

	if player_id == multiplayer.get_unique_id():
		move_controller.move([character], input_axis)

func interact_entity(entity):
	if not is_instance_valid(entity):
		return
	if entity.is_in_group("resource"):
		player.show_entity_informations(entity, player_id)
		character.attack.set_repair_mode(false)
		character.attack.set_target(entity)
	elif entity.controlled_by == player_id:
		if entity is TdBuilding:
			character.attack.set_repair_mode(true)
			character.attack.set_target(entity)

func repair_entity():
	pass

func stop_interact_entity(_entity):
	character.attack.set_target(null)

func _unhandled_input(event):
	input_axis.x = Input.get_axis("Left", "Right")
	input_axis.y = Input.get_axis("Top", "Bottom")
	if event is InputEventMouseButton and event.is_pressed():
		player.reset_state()
		#if is_instance_valid(character.attack.target):
			#character.attack.target.selection.set_target_indicator(false)
			#character.attack.set_target(null)
		if event.button_index == MOUSE_BUTTON_LEFT:
			player.hide_entity_informations(player_id)
			if is_instance_valid(last_select):
				last_select.action_panel.set_source([])
	#if Input.is_action_pressed("action_slot_1"):
		#selected_skill = skills[0]
		#trigger_action = true
	#elif Input.is_action_pressed("action_slot_2"):
		#selected_skill = skills[1]
		#trigger_action = true
	#elif Input.is_action_pressed("action_slot_3"):
		#selected_skill = skills[2]
		#trigger_action = true
	#elif Input.is_action_pressed("action_slot_4"):
		#selected_skill = skills[3]
		#trigger_action = true
	#else:
		#selected_skill = null
		#trigger_action = false
	#if (Input.is_action_just_released("action_slot_1") or Input.is_action_just_released("action_slot_2") or
		 #Input.is_action_just_released("action_slot_3") or Input.is_action_just_released("action_slot_4")):
		#selected_skill = null
		#trigger_action = false
