class_name Faction
extends Resource

@export var id: String
@export var hostile_ids: Array[FactionEnum.Value]

func is_hostile_to(other: Faction) -> bool:
	if other == null:
		return false

	# Convert other.id ("PLAYER") -> enum int
	if not FactionEnum.Value.has(other.id):
		push_warning("Unknown faction id: %s" % other.id)
		return false

	var other_enum: int = FactionEnum.Value[other.id]
	return hostile_ids.has(other_enum)
