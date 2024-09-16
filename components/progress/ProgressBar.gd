extends TextureProgressBar

@export var target: Node
@export var watched_property: String

func _ready():
	value = floor(int(target[watched_property] * 100 / target["max_"+watched_property]))
	target.property_change.connect(update)

func update():
	value = floor(int(target[watched_property] * 100 / target["max_"+watched_property]))
