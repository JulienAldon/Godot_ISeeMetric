extends Entity
class_name RtsCharacter

@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var network: NetworkComponent
@export var movement: NavigationComponent
@export var sprite: AnimatedSprite2D
@export var selection: SelectionComponent
@export var attack: AttackComponent
@export var death: DeathComponent
@export var animation: AnimationController
@export var behaviours: StateMachine
@export var action_controller: ActionComponent

@export var player_marker: ColorRect

var spawn_path: Array

func _enter_tree():
	if network:
		network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)
	player_marker.material.set_shader_parameter("color", GameManager.get_player_color(controlled_by))

func _ready():
	if spawn_path.size() > 0:
		command_navigation(spawn_path[spawn_path.size() - 1], {}, spawn_path)

func dispawn():
	death.death(attacker_id)

func deactivate_behaviour():
	selection.set_target_indicator(false)
	player_marker.hide()
	movement.set_process(false)
	movement.set_physics_process(false)
	attack.set_process(false)
	attack.set_physics_process(false)
	animation.animation_tree.active = false
	hitbox.disabled = true
	behaviours.set_process(false)
	behaviours.set_physics_process(false)
	set_process(false)
	set_physics_process(false)

func append_navigation(pos: Vector2, group, _path: Array) -> void:
	behaviours.on_transition("move")
	movement.set_target_position(pos)
	movement.set_movement_group(group)
	movement.set_path(movement.path + _path.slice(1), movement.current_path_position)

func command_navigation(pos: Vector2, group, _path: Array) -> void:
	behaviours.on_transition("move")
	movement.set_target_position(pos)
	movement.set_movement_group(group)
	movement.set_path(_path, 0)
	
func _process(_delta):
	if not is_multiplayer_authority():
		return
	if health.health <= 0:
		dispawn()
	if attack.is_target_in_attack_range():
		behaviours.on_transition("attack")
	elif movement.has_move_instruction():
		behaviours.on_transition("move")
	else:
		behaviours.on_transition("idle")
