extends Node2D

class_name CharacterStats

@export var health: HealthComponent

@export var attack_speed: float = 3
@export var cast_speed: float = 3
@export var base_range: float = 100

@export var weapons: Array[Weapon]
@export var current_weapon: int = 0
@export var additionnal_projectiles: int = 1
@export var additionnal_duration: int = 0
@export var max_health := 1000
@export var move_speed := 40

@export var added_physical_damage_sources := []
@export var added_magic_damage_sources := []

@export var additionnal_behaviours : Array[String] = []
@export var additionnal_effects : Array[EffectResource] = []
#@export var added_lighting_damage_sources := []
#@export var added_fire_damage_sources := []
#@export var added_cold_damage_sources := []

@export var increased_damage_sources := []
@export var increased_physical_damage_sources := []
@export var increased_magic_damage_sources := []
#@export var increased_fire_damage_sources := []
#@export var increased_cold_damage_sources := []
#@export var increased_lighting_damage_sources := []

@export var more_damage_sources := []
@export var more_physical_damage_sources := []
@export var more_magic_damage_sources := []
#@export var more_fire_damage_sources := []
#@export var more_cold_damage_sources := []
#@export var more_lighting_damage_sources := []

@export var armor: int = 0

func calculate_hit_damage(damage: int) -> int:
	return ceil(damage * float(float(100) / float(100 + get_armor())))

func get_armor() -> int:
	return armor

func get_max_health():
	return max_health

func get_projectiles_number(skill: Skill):
	if skill.projectiles_scallable:
		return skill.projectiles + additionnal_projectiles
	return skill.projectiles

func get_skill_speed(skill: Skill):
	var speed = attack_speed
	if skill.type == Skill.SkillType.Spell:
		speed = cast_speed
	return speed

func calculate_effect_duration(effect: EffectResource):
	if not get_weapon():
		return effect.base_duration + additionnal_duration
	return effect.base_duration + get_weapon().duration + additionnal_duration

func get_skill_effects(skill: Skill):
	var effects: Array[Dictionary] = []
	for effect in skill.effects + additionnal_effects:
		var dict_effect = effect.serialize()
		dict_effect["duration"] = calculate_effect_duration(effect)
		effects.append(dict_effect)
	return effects

func get_skill_behaviours(skill: Skill):
	if not get_weapon():
		return skill.behaviours + additionnal_behaviours
	return skill.behaviours + additionnal_behaviours + get_weapon().additionnal_behaviours

func get_skill_duration(skill: Skill):
	if not get_weapon():
		return skill.base_duration  + additionnal_duration
	return skill.base_duration  + additionnal_duration + get_weapon().duration

func get_skill_throw_speed(skill: Skill):
	if not get_weapon():
		return skill.throw_speed
	return skill.throw_speed + get_weapon().throw_speed

func set_weapon(weapon_index):
	current_weapon = weapon_index

func get_range():
	return base_range

func get_weapon():
	if weapons.size() <= 0:
		return false
	return weapons[current_weapon]

func calculate_added_physical():
	var total_added_physical_damage := 0
	
	for dmg in added_physical_damage_sources:
		total_added_physical_damage += dmg
	return total_added_physical_damage

func calculate_added_magic():
	var total_added_magic_damage := 0
	
	for dmg in added_magic_damage_sources:
		total_added_magic_damage += dmg
	return total_added_magic_damage

func calculate_increased():
	var total_increased_damage := 1
	
	for dmg in increased_damage_sources:
		total_increased_damage += dmg
	return total_increased_damage

func calculate_increased_magic():
	if increased_magic_damage_sources.size() <= 0:
		return 0
	var total_increased_magic_damage := 1
	
	for dmg in increased_magic_damage_sources:
		total_increased_magic_damage += dmg
	return total_increased_magic_damage

func calculate_increased_physical():
	if increased_physical_damage_sources.size() <= 0:
		return 0
	var total_increased_physical_damage := 1
	
	for dmg in increased_physical_damage_sources:
		total_increased_physical_damage += dmg
	return total_increased_physical_damage

func calculate_more():
	var total_more_damage: float = 1
	
	for dmg in more_damage_sources:
		total_more_damage *= 1 + (dmg / 100)
	return total_more_damage

func calculate_more_magic():
	if more_magic_damage_sources.size() <= 0:
		return 0
	var total_more_magic_damage: float = 1
	
	for dmg in more_magic_damage_sources:
		total_more_magic_damage *= 1 + (dmg / 100)
	return total_more_magic_damage

func calculate_more_physical():
	if more_physical_damage_sources.size() <= 0:
		return 0
	var total_more_physical_damage: float = 1
	for dmg in more_physical_damage_sources:
		total_more_physical_damage *= 1 + (dmg / 100)
	return total_more_physical_damage

func calculate_physical_damage(skill: Skill):
	var damage = Damage.new()
	damage.base = (skill.damage.base * skill.damage_effectiveness)
	if skill.type == Skill.SkillType.Attack and get_weapon():
		damage.base += (get_weapon().damage.base * get_weapon().damage_effectiveness)
	damage.added += calculate_added_physical()
	damage.increased = calculate_increased_physical() + calculate_increased()
	damage.more = calculate_more_physical() + calculate_more()
	return damage

func calculate_magic_damage(skill: Skill):
	var damage = Damage.new()
	damage.base = (skill.damage.base * skill.damage_effectiveness)
	if skill.type == Skill.SkillType.Attack and get_weapon():
		damage.base += (get_weapon().damage.base * get_weapon().damage_effectiveness)
	damage.added += calculate_added_magic()
	damage.increased = calculate_increased_magic() + calculate_increased()
	damage.more = calculate_more_magic() + calculate_more()
	return damage

func calculate_skill_damage(skill: Skill):
	var types_funcs = {
		Skill.DamageType.physical: calculate_physical_damage(skill),
		Skill.DamageType.magic: calculate_magic_damage(skill),
	}
	return types_funcs[skill.damage_type]

func get_compatible_weapon(skill: Skill):
	var index = 0
	for weapon in weapons:
		if weapon.type in skill.weapon_compatibility:
			return index
		index += 1
	return null

func add_stats(stats: Array):
	for stat in stats:
		if self[stat.name] is Array:
			self[stat.name].append(stat.value)
		else:
			self[stat.name] += stat.value
		if stat.name == "max_health":
			health.change_max_health(max_health)
