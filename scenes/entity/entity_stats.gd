extends Node2D

class_name EntityStats

@export var health: HealthComponent

@export var attack_speed: float = 3
@export var attack_speed_sources := {}

@export var cast_speed: float = 3
@export var cast_speed_sources := {}

@export var base_range: float = 100
@export var base_range_sources := {}

@export var weapons: Array[Weapon]
@export var current_weapon: int = 0

@export var additionnal_projectiles: int = 1
@export var additionnal_projectiles_sources := {}

@export var additionnal_duration: int = 0
@export var additionnal_duration_sources := {}

@export var max_health := 1000
@export var max_health_sources := {}

@export var health_regeneration := 0
@export var health_regeneration_sources := {}

@export var move_speed := 40
@export var move_speed_sources := {}

@export var added_physical_damage_sources := {}
@export var added_magic_damage_sources := {}

@export var additionnal_behaviours : Array[String] = []
@export var additionnal_effects : Array[EffectResource] = []
#@export var added_lighting_damage_sources := {}
#@export var added_fire_damage_sources := {}
#@export var added_cold_damage_sources := {}

@export var increased_damage_sources := {}
@export var increased_physical_damage_sources := {}
@export var increased_magic_damage_sources := {}
#@export var increased_fire_damage_sources := {}
#@export var increased_cold_damage_sources := {}
#@export var increased_lighting_damage_sources := {}

@export var more_damage_sources := {}
@export var more_physical_damage_sources := {}
@export var more_magic_damage_sources := {}
#@export var more_fire_damage_sources := {}
#@export var more_cold_damage_sources := {}
#@export var more_lighting_damage_sources := {}

@export var armor: int = 0
@export var armor_sources := {}

@export var magic_resist: int = 0
@export var magic_resist_sources := {}

func sum(acc, num):
	return acc + num

func calculate_added_physical():
	var total_added_physical_damage := 0
	
	for dmg in added_physical_damage_sources.values():
		total_added_physical_damage += dmg
	return total_added_physical_damage

func calculate_added_magic():
	var total_added_magic_damage := 0
	
	for dmg in added_magic_damage_sources.values():
		total_added_magic_damage += dmg
	return total_added_magic_damage

func calculate_increased():
	var total_increased_damage := 1
	
	for dmg in increased_damage_sources.values():
		total_increased_damage += dmg
	return total_increased_damage

func calculate_increased_magic():
	if increased_magic_damage_sources.size() <= 0:
		return 0
	var total_increased_magic_damage := 1
	
	for dmg in increased_magic_damage_sources.values():
		total_increased_magic_damage += dmg
	return total_increased_magic_damage

func calculate_increased_physical():
	if increased_physical_damage_sources.size() <= 0:
		return 0
	var total_increased_physical_damage := 1
	
	for dmg in increased_physical_damage_sources.values():
		total_increased_physical_damage += dmg
	return total_increased_physical_damage

func calculate_more():
	var total_more_damage: float = 1
	
	for dmg in more_damage_sources.values():
		total_more_damage *= 1 + (dmg / 100)
	return total_more_damage

func calculate_more_magic():
	if more_magic_damage_sources.size() <= 0:
		return 0
	var total_more_magic_damage: float = 1
	
	for dmg in more_magic_damage_sources.values():
		total_more_magic_damage *= 1 + (dmg / 100)
	return total_more_magic_damage

func calculate_more_physical():
	if more_physical_damage_sources.size() <= 0:
		return 0
	var total_more_physical_damage: float = 1
	for dmg in more_physical_damage_sources.values():
		total_more_physical_damage *= 1 + (dmg / 100)
	return total_more_physical_damage

func calculate_physical_damage(skill: SkillResource):
	var damage = Damage.new()
	damage.base = (skill.damage.base * skill.damage_effectiveness)
	if skill.type == SkillResource.SkillType.ATTACK and get_weapon():
		damage.base += (get_weapon().damage.base * get_weapon().damage_effectiveness)
	damage.added += calculate_added_physical()
	damage.increased = calculate_increased_physical() + calculate_increased()
	damage.more = calculate_more_physical() + calculate_more()
	return damage

func calculate_magic_damage(skill: SkillResource):
	var damage = Damage.new()
	damage.base = (skill.damage.base * skill.damage_effectiveness)
	if skill.type == SkillResource.SkillType.ATTACK and get_weapon():
		damage.base += (get_weapon().damage.base * get_weapon().damage_effectiveness)
	damage.added += calculate_added_magic()
	damage.increased = calculate_increased_magic() + calculate_increased()
	damage.more = calculate_more_magic() + calculate_more()
	return damage

func calculate_skill_damage(skill: SkillResource):
	var types_funcs = {
		SkillResource.DamageType.PHYSICAL: calculate_physical_damage(skill),
		SkillResource.DamageType.MAGIC: calculate_magic_damage(skill),
	}
	return types_funcs[skill.damage_type]

func calculate_hit_damage(damage: int, damage_type: SkillResource.DamageType) -> int:
	if damage_type == SkillResource.DamageType.NONE:
		return damage
	var mitigations = [get_armor(), get_magic_resist()]
	return ceil(damage * float(float(100) / float(100 + mitigations[int(damage_type-1)])))

func calculate_effect_duration(effect: EffectResource):
	if not get_weapon():
		return effect.base_duration + get_duration()
	return effect.base_duration + get_weapon().duration + get_duration()

func get_projectiles_number(skill: SkillResource):
	if skill.projectiles_scallable:
		return skill.projectiles + additionnal_projectiles
	return skill.projectiles

func get_skill_speed(skill: Skill):
	var speed = get_attack_speed()
	if skill.type == SkillResource.SkillType.SPELL:
		speed = get_cast_speed()
	return speed

func get_skill_effects(skill: SkillResource):
	var effects: Array[Dictionary] = []
	for effect in skill.effects + additionnal_effects:
		var dict_effect = effect.serialize()
		dict_effect["duration"] = calculate_effect_duration(effect)
		effects.append(dict_effect)
	return effects

func get_skill_behaviours(skill: SkillResource):
	if not get_weapon():
		return skill.behaviours + additionnal_behaviours
	return skill.behaviours + additionnal_behaviours + get_weapon().additionnal_behaviours

func get_skill_duration(skill: SkillResource):
	if not get_weapon():
		return skill.base_duration  + additionnal_duration
	return skill.base_duration  + additionnal_duration + get_weapon().duration

func get_skill_throw_speed(skill: SkillResource):
	if not get_weapon():
		return skill.throw_speed
	return skill.throw_speed + get_weapon().throw_speed

func set_weapon(weapon_index):
	current_weapon = weapon_index

func get_range():
	return base_range_sources.values().reduce(sum, base_range)

func get_magic_resist() -> int:
	return magic_resist_sources.values().reduce(sum, magic_resist)

func get_armor() -> int:
	return armor_sources.values().reduce(sum, armor)

func get_max_health():
	return max_health_sources.values().reduce(sum, max_health)

func get_attack_speed():
	return attack_speed_sources.values().reduce(sum, attack_speed)

func get_cast_speed():
	return cast_speed_sources.values().reduce(sum, cast_speed)

func get_duration():
	return additionnal_duration_sources.values().reduce(sum, additionnal_duration)

func get_health_regeneration():
	return health_regeneration_sources.values().reduce(sum, health_regeneration)

func get_weapon():
	if weapons.size() <= 0:
		return false
	return weapons[current_weapon]

func get_compatible_weapon(skill: SkillResource):
	var index = 0
	for weapon in weapons:
		if weapon.type in skill.weapon_compatibility:
			return index
		index += 1
	return null

func remove_stats(stats: Array[Stat], source: String):
	for stat in stats:
		if stat.name+"_sources" in self:
			self[stat.name+"_sources"].erase(source)
		if stat.name == "max_health":
			health.change_max_health(get_max_health())

func add_stats(stats: Array[Stat], source: String):
	for stat in stats:
		if stat.name+"_sources" in self:
			self[stat.name+"_sources"][source] = stat.value
		if stat.name == "max_health":
			health.change_max_health(get_max_health())
