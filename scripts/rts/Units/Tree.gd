extends StaticBody2D

@export var network: NetworkComponent
@export var selection: SelectionComponent
@export var health: HealthComponent
@export var harvest: HarvestComponent

var type := Production.Entity.WoodTree
var resource_type := Production.Resources.Wood
