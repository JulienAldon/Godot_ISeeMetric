extends Controller
class_name HnsController

var input_axis: Vector2
var trigger_action: bool = false
var selected_skill
@export var character: Node2D
@onready var stats: Node2D = character.stats
@onready var skills: Array[Node] = character.skills.get_children()

var anim_names = [
	"Attack",
	"Attack",
	"Projectile_Attack"
]

func _ready():
	super()
	character.controlled_by = player_id

func move(entities):
	for child in entities:
		child.movement.set_input_axis(input_axis)
	if entities.size() > 0 and player_id == multiplayer.get_unique_id():
		var pos = entities[0].position
		camera.position = pos

func _physics_process(_delta):
	move([character])

func respawn():
	character.health.reset()
	character.position = Vector2(0, 0)

func trigger_skill(attack_slot):
	if not attack_slot.skill.is_skill_valid():
		return
	var weapon_index = stats.get_compatible_weapon(attack_slot.skill)
	if weapon_index == null:
		return
	var weapon = stats.weapons[weapon_index]
	var new_animation_duration = 1 / stats.get_skill_speed(attack_slot.skill)
	if attack_slot.can_trigger:
		if attack_slot.skill.movement:
			var mouse_dir = (get_global_mouse_position() - character.attack_point.global_position).normalized()
			character.movement.dash(mouse_dir)
		stats.set_weapon(weapon_index)
		attack_slot.set_timer(new_animation_duration)
		var informations = {
			"controlled_by": player.player_id,
			"position": character.global_position,
			"rotation": character.attack_point.rotation,
			"animation_speed": 1,
			"damage": stats.calculate_skill_damage(attack_slot.skill).calculate(),
			"invoker_path": character.get_path(),
			"throw_speed": stats.get_skill_throw_speed(attack_slot.skill),
			"duration": stats.get_skill_duration(attack_slot.skill),
			"mouse_pos": get_global_mouse_position(),
			"behaviours_models": stats.get_skill_behaviours(attack_slot.skill),
			"effects": stats.get_skill_effects(attack_slot.skill),
			"damage_type": attack_slot.skill.damage_type
		}
		attack_slot.trigger_skill.rpc_id(1, informations)
		character.animation.set_is_attack(stats.get_skill_speed(attack_slot.skill), (get_global_mouse_position() - character.global_position).normalized() , anim_names[weapon.type])
		attack_slot.reset_timer()

func _process(_delta):
	if character.health.health <= 0:
		respawn()
	if !player_id == multiplayer.get_unique_id():
		return
	character.weapon.frame = stats.get_weapon().style
	if trigger_action and selected_skill:
		trigger_skill(selected_skill)

func _unhandled_input(_event):
	if Input.is_action_pressed("action_slot_1"):
		selected_skill = skills[0]
		trigger_action = true
	elif Input.is_action_pressed("action_slot_2"):
		selected_skill = skills[1]
		trigger_action = true
	elif Input.is_action_pressed("action_slot_3"):
		selected_skill = skills[2]
		trigger_action = true
	elif Input.is_action_pressed("action_slot_4"):
		selected_skill = skills[3]
		trigger_action = true
	else:
		selected_skill = null
		trigger_action = false
	input_axis.x = Input.get_axis("Left", "Right")
	input_axis.y = Input.get_axis("Top", "Bottom")
	if (Input.is_action_just_released("action_slot_1") or Input.is_action_just_released("action_slot_2") or
		 Input.is_action_just_released("action_slot_3") or Input.is_action_just_released("action_slot_4")):
		selected_skill = null
		trigger_action = false
