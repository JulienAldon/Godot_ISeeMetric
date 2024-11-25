extends Node2D

class_name UpgradeComponent

enum UpgradeTiers {
	BASIC,
	TIER1,
	TIER2,
	TIER3,
}

var current_tier: int

@export var max_tier: int
@export var action_controller: ActionComponent
@export var stats: EntityStats
@export var upgrades_per_tier: Dictionary

func can_upgrade():
	return current_tier < max_tier

func get_upgrade_tier() -> Array:
	if current_tier >= max_tier:
		return []
	current_tier += 1
	if current_tier > max_tier:
		return []
	return upgrades_per_tier[current_tier]
