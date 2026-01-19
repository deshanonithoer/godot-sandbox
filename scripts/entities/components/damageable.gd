class_name Damageable
extends Node

@export var entity: Entity
func _ready():
	entity = get_parent() as Entity

signal died

func take_damage(amount: int, source: Entity) -> void:
	if entity == null: 
		return
		
	entity.take_damage(amount, source)
	
	if entity.health <= 0:
		died.emit()
