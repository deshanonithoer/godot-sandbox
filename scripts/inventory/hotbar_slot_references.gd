extends Node
class_name HotbarSlotReferences

signal hotbar_changed()

@export var hotbar_slot_count: int = 5

# hotbar_slot_index -> inventory_slot_index
var hotbar_to_inventory_slot_map: Array[int] = []

var selected_hotbar_slot_index: int = 0

func _ready() -> void:
	hotbar_to_inventory_slot_map.resize(hotbar_slot_count)
	for hotbar_slot_index in range(hotbar_slot_count):
		hotbar_to_inventory_slot_map[hotbar_slot_index] = hotbar_slot_index

func set_selected_hotbar_slot_index(new_hotbar_slot_index: int) -> void:
	selected_hotbar_slot_index = clamp(new_hotbar_slot_index, 0, hotbar_slot_count - 1)
	hotbar_changed.emit()

func get_selected_inventory_slot_index() -> int:
	return hotbar_to_inventory_slot_map[selected_hotbar_slot_index]

func rebind_hotbar_slot(hotbar_slot_index: int, inventory_slot_index: int) -> void:
	if hotbar_slot_index < 0 or hotbar_slot_index >= hotbar_slot_count:
		return
	hotbar_to_inventory_slot_map[hotbar_slot_index] = inventory_slot_index
	hotbar_changed.emit()
