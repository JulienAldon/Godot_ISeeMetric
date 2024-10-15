extends Node2D

class_name BuildComponent
@export_group("Dependencies")
@export var action_controller: ActionComponent
@export var entity: Entity

@export_group("Intern")
@export var build_mode: BuildMode

var buildings: Array = []
var build_mode_enabled: bool = false
var build_action: Build

func _ready():
	build_mode.PositionConfirmed.connect(build_position_selected)

# Enter build mode status
func set_action_build_mode(action: Build):
	build_mode.show_build_mode()
	build_action = action

# Queue action after build mode has targeted a position
func build_position_selected(pos: Vector2):
	if not build_action:
		build_mode.hide_build_mode()
		return
	if action_controller.can_queue_action():
		var player = GameManager.get_player(multiplayer.get_unique_id())
		player.spend_currency(build_action.cost)
		action_controller.queue_action(build_action, pos)
	else:
		build_mode.reset_build_state()
	build_mode.hide_build_mode()

@rpc("call_local", "any_peer")
func destroy_buildings(capturing_player: int):
	for building in buildings:
		if building.controlled_by != capturing_player:
			building.attacker_id = capturing_player
			building.hitbox.damage.rpc(building.health.max_health)

func _on_effect_range_body_entered(body):
	if body.is_in_group("building") and body != entity:
		buildings.append(body)

func _on_effect_range_body_exited(body):
	if body.is_in_group("building"):
		buildings.erase(body)
