extends Node2D

class_name UpgradeComponent

enum UpgradeTiers {
	Basic,
	Tier1,
	Tier2,
	Tier3,
}

var current_tier: int

@export var stats: CharacterStats
@export var upgrades_per_tier: Dictionary

func add_upgrade_tier():
	if current_tier >= 3:
		return
	current_tier += 1
	if current_tier >= 3:
		pass
	stats.add_stats(upgrades_per_tier[current_tier])
