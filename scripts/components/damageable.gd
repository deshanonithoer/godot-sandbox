class_name Damageable
extends Node

@export var entity: Entity

func _ready() -> void:
	entity = get_parent() as Entity

func take_damage(amount: int, source: Entity) -> void:
	if entity == null or source == null:
		return

	entity.request_damage.rpc_id(
		entity.get_multiplayer_authority(),
		amount,
		source.get_path()
	)
