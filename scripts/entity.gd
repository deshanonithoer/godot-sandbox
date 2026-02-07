class_name Entity
extends CharacterBody2D

@export var max_health := 100
@export_storage var health := max_health
@export var faction: Faction

signal died

# Validate if this entity is hostile towards another entity based on their factions
func is_hostile_to(other: Entity) -> bool:
	if faction == null or other == null or other.faction == null:
		return false
	return faction.is_hostile_to(other.faction)
	
# Take damage from another entity
#@rpc("authority")
#func take_damage(amount: int, source_path: NodePath) -> void:
	#var source := get_node_or_null(source_path) as Entity
	#if source and not source.is_hostile_to(self):
		#return
#
	#health -= amount
	#if health <= 0:
		#died.emit()
		#_die()

#@rpc("any_peer")
#func request_damage(amount: int, source_path: NodePath) -> void:
	#if not is_multiplayer_authority():
		#return
#
	#var source := get_node_or_null(source_path) as Entity
	#if source and not source.is_hostile_to(self):
		#return
#
	#_apply_damage(amount)
	
func _apply_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit()
		_die()
	
# RIP
func _die() -> void:
	if is_multiplayer_authority():
		queue_free()
