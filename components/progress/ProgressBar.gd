extends TextureProgressBar

class_name CustomProgresBar

@export var target: Node
@export var watched_property: String

func _ready():
	value = floor(int(target[watched_property] * 100 / target["max_"+watched_property]))
	target.property_change.connect(update)

func update():
	self.show()
	value = floor(int(target[watched_property] * 100 / target["max_"+watched_property]))
