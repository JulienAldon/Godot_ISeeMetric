extends CharacterBody2D

@export var navigation: NavigationComponent
@export var health: HealthComponent
@export var hitbox: HitboxComponent
@export var selection: SelectionComponent
@export var network: NetworkComponent
@export var production: ProductionComponent
@export var harvest: HarvesterComponent

var type := Production.Entity.Worker
var controlled_by: int

func _ready():
	network.set_authority(controlled_by)
	set_multiplayer_authority(controlled_by)
#const Resources = preload("res://scripts/Rts/Buildings/Production.gd").Resources
#
## Harvesting
#@export var harvest_force: int = 25
#@export var max_resource_quantity: int = 100
#var current_resource_quantity: int = 0
#var current_resource_type: Resources = Resources.None
#var can_harvest: bool = true
#var deposit_entity: Node2D
#var resource_deposit_path
#var in_harvest_range: bool = false
## Building
#
## Actions
#var target_action_entity: Node2D
#
#func _ready():
	#super._ready()
#
#func set_manual_action(prod: Production):
	## build
	#pass
#
#func is_inventory_full():
	#return current_resource_quantity >= max_resource_quantity
#
#func is_inventory_empty():
	#return current_resource_quantity == 0 or current_resource_type == Resources.None
#
#func reached_target(distance: int = 50, _target_position=self.target_position) -> bool:
	#return position.distance_to(_target_position) < distance
#
#func go_to_resource():
	#if !is_instance_valid(target_action_entity):
		#current_action = Actions.Idle
		#return
	#print("go to respurce ", target_action_entity.position)
	#set_target_position(target_action_entity.position)
	#set_movement_group([{"collider": self}])
	#var new_path = resource_deposit_path.duplicate()
	#new_path.reverse()
	#set_path(new_path.slice(1))
	#current_action = Actions.MoveHarvest
#
#func go_to_deposit():
	#if !is_instance_valid(deposit_entity):
		#stop()
		#return
	#print("go to deposit ", deposit_entity.position)
	#set_target_position(deposit_entity.position)
	#set_movement_group([{"collider": self}])
	#set_path(resource_deposit_path.slice(1))
	#current_action = Actions.MoveDeposit
#
#func stop():
	#set_target_position(position)
	#current_action = Actions.Idle
#
#func _physics_process(_delta):
	#super._physics_process(_delta)
	#if current_action == Actions.MoveHarvest:
		#if !is_instance_valid(target_action_entity):
			#go_to_deposit()
		#elif reached_target(50, target_action_entity.position) and !is_inventory_full():
			#harvest()
	#elif current_action == Actions.Harvest:
		#if !is_instance_valid(target_action_entity):
			#go_to_deposit()
		#elif is_inventory_full():
			#go_to_deposit()
		#else:
			#harvest()
	#elif current_action == Actions.MoveDeposit:
		#if !is_instance_valid(deposit_entity):
			#stop()
		#if reached_target(100, deposit_entity.position) and !is_inventory_empty():
			#deposit()
	#elif current_action == Actions.Deposit:
		#if is_inventory_empty():
			#go_to_resource()
#
#func set_deposit(value):
	#deposit_entity = value
#
#func set_deposit_path(value):
	#resource_deposit_path = value
#
#func deposit():
	#current_action = Actions.Deposit
	#deposit_entity.add_resources(current_resource_type, current_resource_quantity)
	#current_resource_quantity = 0
	#current_resource_type = Resources.None
	#print("deposit ", current_resource_type, current_resource_quantity)
	#
#func set_action_entity(entity: Node2D):
	#print("target ressource")
	#if entity.is_in_group("resource"):
		#current_action = Actions.MoveHarvest
	#if entity.is_in_group("building") and entity.type == "center":
		#current_action = Actions.MoveDeposit
	#target_action_entity = entity
		#
#func harvest():
	##set animation state
	#animation_state = AnimState.Harvest
	#current_action = Actions.Harvest
	#if can_harvest:
		#print("harvesting")
		#$HarvestCooldown.start()
		#if is_instance_valid(target_action_entity):
			#if current_resource_type != Resources.None and target_action_entity.get_type() != current_resource_type:
				#current_resource_quantity = 0
			#current_resource_quantity += target_action_entity.harvest(harvest_force)
			#current_resource_type = target_action_entity.get_type()
			#print(current_resource_quantity, " ", current_resource_type)
		#can_harvest = false
#
#func _on_harvest_cooldown_timeout():
	#can_harvest = true
	#
#func _on_harvest_range_body_entered(body):
	#in_harvest_range = body.is_in_group("resource")
#
#func _on_harvest_range_body_exited(_body):
	#in_harvest_range = false
