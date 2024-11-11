extends Effect

func start(_character):
	super.start(_character)
	if "upgrade" in character:
		var upgrades = character.upgrade.get_upgrade_tier()
		character.stats.add_stats(upgrades)
		description = create_upgrade_description(upgrades)

func format_stat(el: Stat)->String: 
	return el.display_name + ": +" + str(el.value)

func create_upgrade_description(upgrades: Array):
	return "\n".join(upgrades.map(format_stat))
