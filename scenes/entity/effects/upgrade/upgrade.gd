extends Effect

class_name Upgrade

@export var stats: Array[Stat]
@export var skill: SkillResource

func start(_character):
	super.start(_character)
	character.stats.add_stats(stats, str(get_instance_id()) + title)
	description = create_upgrade_description(stats)
	if skill and "attack" in character and "set_skill" in character.attack.attack_style:
		character.attack.attack_style.set_skill(skill)

func format_stat(el: Stat)->String: 
	return el.display_name + ": " + str(el.value)

func create_upgrade_description(upgrades: Array[Stat]):
	return "\n".join(upgrades.map(format_stat))

func stop():
	character.stats.remove_stats(stats, str(get_instance_id()) + title)
	if skill and "attack" in character and "set_default_skill" in character.attack.attack_style:
		character.attack.attack_style.set_default_skill()
