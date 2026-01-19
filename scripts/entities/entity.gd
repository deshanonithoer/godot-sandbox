class_name Entity
extends CharacterBody2D

@export var max_health := 100
var health := max_health

@export var faction: Faction
	
# Validate if this entity is hostile towards another entity based on their factions
func is_hostile_to(other: Entity) -> bool:
	if faction == null or other == null or other.faction == null:
		return false
	return faction.is_hostile_to(other.faction)
	
# Take damage from another entity
func take_damage(amount: int, source: Entity) -> void:
	if source and not source.is_hostile_to(self):
		return

	health -= amount
	if health <= 0:
		_die()

# RIP
func _die() -> void:
	queue_free()
