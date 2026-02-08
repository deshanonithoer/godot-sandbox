class_name InventoryContainer
extends Node

signal inventory_changed(inventory_snapshot: Array)

@export var total_slot_count: int = 15

var item_definitions_by_id: Dictionary = {}
var slot_contents: Array = []

func _ready() -> void:
	slot_contents.resize(total_slot_count)
	for slot_index in range(total_slot_count):
		slot_contents[slot_index] = null
		
func get_stack_in_slot(slot_index) -> InventoryItemStack:
	if !_slot_in_range(slot_index):
		return null
		
	return slot_contents[slot_index]
	
func _set_stack_in_slot(slot_index: int, stack: InventoryItemStack) -> void:
	if !_slot_in_range(slot_index):
		return
		
	slot_contents[slot_index] = stack
	_emit_inventory_changed()
	
func _emit_inventory_changed() -> void:
	inventory_changed.emit(create_network_snapshot())
	
func _get_max_stack_size_for_item(item_id: StringName) -> int:
	var item_definition: ItemDefinition = item_definitions_by_id.get(item_id, null)
	if item_definition == null:
		return 1
		
	return max(1, item_definition.max_stack_size)

#region Snapshots (server -> client)
func create_network_snapshot() -> Array:
	var snapshot: Array = []
	snapshot.resize(slot_contents.size())
	
	for slot_index in range(slot_contents.size()):
		var stack: InventoryItemStack = slot_contents[slot_index]
		snapshot[slot_index] = null
		
		if stack == null or stack.is_empty():
			return snapshot
			
		snapshot[slot_index] = {
			"item_id": stack.item_id,
			"quantity": stack.quantity,
			"instance_properties": stack.instance_properties
		}
		
	return snapshot
	
func apply_network_snapshot(snapshot: Array) -> void:
	slot_contents.resize(snapshot.size())
	
	for slot_index in range(snapshot.size()):
		slot_contents[slot_index] = null
		
		var slot_value = snapshot[slot_index]
		if slot_value == null: 
			continue
			
		slot_contents[slot_index] = InventoryItemStack.new(
			slot_value["item_id"],
			int(slot_value["quantity"]),
			slot_value.get("instance_properties", {})
		)
		
	_emit_inventory_changed()
#endregion
	
#region Add / Remove item
func can_add_item(item_id: StringName, quantity: int, instance_properties: Dictionary = {}) -> bool:
	return add_item(item_id, quantity, instance_properties, true) == 0
	
func add_item(
	item_id: StringName,
	quantity: int,
	instance_properties: Dictionary = {},
	is_dry_run: bool = false
):
	if quantity <= 0:
		return 0
		
	var max_stack_size: int = _get_max_stack_size_for_item(item_id)
	var remaining_quantity: int = quantity
	
	# Fill existing ones first
	for slot_index in range(slot_contents.size()):
		var existing_stack: InventoryItemStack = slot_contents[slot_index]
		if existing_stack == null:
			continue
			
		var is_same_item: bool = existing_stack.item_id == item_id
		var is_same_instance: bool = existing_stack.instance_properties == instance_properties
		if not (is_same_item and is_same_instance):
			continue
			
		if existing_stack.quantity >= max_stack_size:
			continue
			
		var available_space: int = max_stack_size - existing_stack.quantity
		var amount_to_add: int = min(available_space, remaining_quantity)
		
		if amount_to_add > 0:
			if not is_dry_run:
				existing_stack.quantity += amount_to_add
			remaining_quantity -= amount_to_add
			
		if remaining_quantity == 0:
			if not is_dry_run:
				_emit_inventory_changed()
			return 0
	
	# Fill empty slots
	for slot_index in range(slot_contents.size()):
		if slot_contents[slot_index] != null:
			continue
			
		var amount_to_add: int = min(max_stack_size, remaining_quantity)
		if not is_dry_run:
			slot_contents[slot_index] = InventoryItemStack.new(
				item_id,
				amount_to_add,
				instance_properties
			)
			
		remaining_quantity -= amount_to_add
		if remaining_quantity == 0:
			if not is_dry_run:
				_emit_inventory_changed()
			return 0

	if not is_dry_run:
		_emit_inventory_changed()
	return remaining_quantity
	
func remove_from_slot(slot_index: int, quantity: int) -> int:
	if quantity <= 0:
		return 0
		
	var stack: InventoryItemStack = get_stack_in_slot(slot_index)
	if stack == null:
		return 0
		
	var amount_removed: int = min(quantity, stack.quantity)
	stack.quantity -= amount_removed
	
	if stack.quantity <= 0:
		slot_contents[slot_index] = null
		
	_emit_inventory_changed()
	return amount_removed
#endregion

#region Move / Swap / Merge
func move_or_merge_slot(source_slot_index: int, target_slot_index: int) -> bool:
	if source_slot_index == target_slot_index:
		return false
		
	if source_slot_index < 0 or source_slot_index >= slot_contents.size():
		return false
		
	if target_slot_index < 0 or target_slot_index >= slot_contents.size():
		return false
		
	var source_stack: InventoryItemStack = slot_contents[source_slot_index]
	if source_stack == null or source_stack.is_empty():
		return false
		
	# Move into empty slot
	var target_stack: InventoryItemStack = slot_contents[target_slot_index]
	if target_stack == null or target_stack.is_empty():
		slot_contents[target_slot_index] = source_stack
		slot_contents[source_slot_index] = null
		_emit_inventory_changed()
		return true
		
	# Merge with existing
	if source_stack.can_stack_with(target_stack):
		var max_stack_size: int = _get_max_stack_size_for_item(source_stack.item_id)
		var available_space: int = max_stack_size - target_stack.quantity
		
		if available_space > 0:
			var amount_to_move: int = min(available_space, source_stack.quantity)
			target_stack.quantity += amount_to_move
			source_stack.quantity -= amount_to_move
			
			if source_stack.quantity <= 0:
				slot_contents[source_slot_index] = null
				
			_emit_inventory_changed()
			return true
			
	# Otherwise swap
	slot_contents[target_slot_index] = source_stack
	slot_contents[source_slot_index] = target_stack
	_emit_inventory_changed()
	return true

func split_stack_into_empty_slot(source_slot_index: int, split_quantity: int, empty_target_slot_index: int) -> bool:
	if split_quantity <= 0:
		return false

	if source_slot_index < 0 or source_slot_index >= slot_contents.size():
		return false
	if empty_target_slot_index < 0 or empty_target_slot_index >= slot_contents.size():
		return false
	if source_slot_index == empty_target_slot_index:
		return false

	var source_stack: InventoryItemStack = slot_contents[source_slot_index]
	if source_stack == null:
		return false

	# Require enough to split and target must be empty
	if source_stack.quantity <= split_quantity:
		return false
	if slot_contents[empty_target_slot_index] != null:
		return false

	slot_contents[empty_target_slot_index] = InventoryItemStack.new(
		source_stack.item_id,
		split_quantity,
		source_stack.instance_properties
	)

	source_stack.quantity -= split_quantity
	_emit_inventory_changed()
	return true
#endregion

#region Private helpers
func _slot_in_range(slot_index: int):
	return slot_index >= 0 or slot_index <= slot_contents.size()
#endregion
