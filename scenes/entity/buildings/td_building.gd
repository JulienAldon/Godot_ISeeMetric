extends Building

class_name TdBuilding

var in_outpost_range: bool = false

@export var action_panel: FloatingBuildingAction
@export var time_before_damage: float = 1
@export var hitbox: HitboxComponent
var health_lost = 50
var current_rime: float = 0

var player: Node2D

func _enter_tree():
	player = GameManager.get_player(controlled_by)
	if not player:
		return
	player.current_controller.add_building(self)

func _exit_tree():
	if not player:
		return
	player.current_controller.remove_building(self)

func is_in_outpost_range():
	var outposts = GameManager.get_level_outposts()
	for outpost in outposts:
		if outpost.controlled_by != controlled_by:
			continue
		var rect: Rect2 = Rect2(outpost.global_position - (outpost.get_area_effect_range().size / 2), outpost.get_area_effect_range().size)
		var build_rect: Rect2 = Rect2(global_position, hitbox.shape.size * 1.2)
		if build_rect.intersects(rect, true):
			return true
	return false
			
func _ready():
	super()
	in_outpost_range = is_in_outpost_range()

func take_damage_tick(delta):
	current_rime += delta
	if current_rime >= time_before_damage:
		self.hitbox.damage.rpc(health_lost, SkillResource.DamageType.NONE, controlled_by)
		current_rime = 0

func _process(_delta):
	pass
	#if not in_outpost_range:
		#take_damage_tick(delta)

func deactivate_behaviour():
	action_panel.hide()
	super()

func trigger_action(action):
	if action is Build:
		self.build.set_action_build_mode(action)
		return
	if self.action_controller:
		if not player.current_controller.can_queue_action(action):
			return
		if self.action_controller.can_queue_action():
			player.spend_currency(action.cost)
			self.action_controller.queue_action(action, global_position)
