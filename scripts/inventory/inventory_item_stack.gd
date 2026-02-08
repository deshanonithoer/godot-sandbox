class_name InventoryItemStack
extends RefCounted

var item_id: StringName
var quantity: int
var instance_properties: Dictionary

func _init(
	new_item_id: StringName = StringName(),
	new_quantity: int = 0,
	new_instance_properties: Dictionary = {}
) -> void:
	item_id = new_item_id
	quantity = new_quantity
	instance_properties = new_instance_properties

func is_empty() -> bool:
	return item_id == StringName() or quantity <= 0
	
func can_stack_with(other_stack: InventoryItemStack) -> bool:
	if other_stack == null:
		return false
		
	return item_id == other_stack.item_id and instance_properties == other_stack.instance_properties
