class_name Entity
extends CharacterBody2D

@export var id := 1
@export var max_health := 100
@export_storage var health := max_health
@export var faction: Faction

signal died

# Validate if this entity is hostile towards another entity based on their factions
func is_hostile_to(other: Entity) -> bool:
	if faction == null or other == null or other.faction == null:
		return false
	return faction.is_hostile_to(other.faction)

func request_damage(amount: int, source: Entity) -> void:
	if source and not source.is_hostile_to(self):
		return

	# Get direction the source was looking in
	var hit_direction: Vector2 = (source.global_position - global_position)
	
	# If they're on the exact same position, avoid NaN / weirdness
	if hit_direction.length_squared() > 0.0001:
		hit_direction = hit_direction.normalized()
		
	apply_damage(amount, hit_direction)
	
func apply_damage(amount: int, hit_direction: Vector2) -> void:
	health -= amount
	if health <= 0:
		died.emit()
		_die()
	
# RIP
func _die() -> void:
	if is_multiplayer_authority():
		queue_free()
