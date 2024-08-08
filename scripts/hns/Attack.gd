extends Node2D

var damage: Damage

func _on_area_2d_body_entered(body):
	if body.has_method("hitbox"):
		body.hitbox.damage(damage) 
