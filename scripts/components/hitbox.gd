class_name Hitbox
extends Area2D

@export var damage := 10
var source: Entity

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Don't attack yourself
	if body == source:
		return

	if body.has_node("Damageable"):
		body.get_node("Damageable").take_damage(damage, source)
