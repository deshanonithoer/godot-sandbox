class_name InventoryController
extends Node

@onready var player: Node = get_tree().current_scene
@onready var inventory_container: InventoryContainer = $"../InventoryContainer"
@onready var hotbar_references: HotbarSlotReferences = $"../HotbarSlotReferences"

@export var item_definitions_by_id: Dictionary

func _ready() -> void:
	inventory_container.item_definitions_by_id = item_definitions_by_id
	
#region Client request helpers
func request_move_inventory_slot(source_slot_index: int, target_slot_index: int) -> void:
	rpc_id(
		NetworkManager.SERVER_PEER_ID,
		"server_request_move_inventory_slot", 
		source_slot_index,
		target_slot_index
	)
	
func request_use_selected_hotbar_item() -> void:
	var selected_inventory_slot_index: int = hotbar_references.get_selected_inventory_slot_index()
	rpc_id(
		NetworkManager.SERVER_PEER_ID,
		"server_request_user_inventory_slot", 
		selected_inventory_slot_index
	)
	
func request_split_inventory_slot(source_slot_index: int, quantity: int, empty_target_slot_index: int) -> void:
	rpc_id(
		NetworkManager.SERVER_PEER_ID,
		"server_request_split_inventory_slot", 
		source_slot_index,
		quantity,
		empty_target_slot_index
	)
	
func request_user_selected_hotbar_item() -> void:
	var selected_inventory_slot_index: int = hotbar_references.get_selected_inventory_slot_index()
	rpc_id(
		NetworkManager.SERVER_PEER_ID,
		"server_request_use_inventory_slot", 
		selected_inventory_slot_index
	)
	
func request_pickup_world_item(network_item_id: int) -> void:
	rpc_id(
		NetworkManager.SERVER_PEER_ID,
		"server_request_pickup_world_item", 
		network_item_id
	)
#endregion

#region Server request handlers
func _is_requesting_peer_the_owner(requesting_peer_id: int) -> bool:
	return requesting_peer_id == player.get_multiplayer_authority()
	
@rpc("any_peer", "reliable")
func server_request_move_inventory_slot(source_slot_index: int, target_slot_index: int) -> void:
	if !multiplayer.is_server():
		return
		
	var requesting_peer_id: int = multiplayer.get_remote_sender_id()
	if not _is_requesting_peer_the_owner(requesting_peer_id):
		return
		
	inventory_container.move_or_merge_slot(source_slot_index, target_slot_index)
	_send_inventory_snapshot_to_owner()
	
@rpc("any_peer", "reliable")
func server_request_use_inventory_slot(inventory_slot_index: int) -> void:
	if !multiplayer.is_server():
		return
		
	var requesting_peer_id = multiplayer.get_remote_sender_id()
	if not _is_requesting_peer_the_owner(requesting_peer_id):
		return
		
	var stack: InventoryItemStack = inventory_container.get_stack_in_slot(inventory_slot_index)
	if stack == null or stack.is_empty():
		return
		
	var item_definition: ItemDefinition = item_definitions_by_id.get(stack.item_id, null)
	if item_definition == null:
		return
		
	match item_definition.use_behaviour:
		ItemDefinition.UseBehaviour.CONSUME:
			inventory_container.remove_from_slot(inventory_slot_index, 1)
			
		ItemDefinition.UseBehaviour.SWING_TOOL:
			# Probably detect what kind of weapon to initiate attack state
			return
			
	_send_inventory_snapshot_to_owner()
	
@rpc("any_peer", "reliable")
func server_request_split_inventory_slot(source_slot_index: int, quantity: int, empty_target_slot_index: int) -> void:
	if !multiplayer.is_server():
		return
		
	var requesting_peer_id: int = multiplayer.get_remote_sender_id()
	if not _is_requesting_peer_the_owner(requesting_peer_id):
		return
		
	inventory_container.split_stack_into_empty_slot(
		source_slot_index, 
		quantity, 
		empty_target_slot_index
	)
	
	_send_inventory_snapshot_to_owner()
	
@rpc("any_peer", "reliable")
func server_request_pickup_world_item(network_item_id: int) -> void:
	if !multiplayer.is_server():
		return
		
	var requesting_peer_id = multiplayer.get_remote_sender_id()
	if not _is_requesting_peer_the_owner(requesting_peer_id):
		return
		
	# TODO find out what item is picked up and what validation rules apply
	var picked_up_item_id: StringName = &"stone_sword"
	var picked_up_quantity: int = 3
	
	var remainder: int = inventory_container.add_item(picked_up_item_id, picked_up_quantity)
	var picked_up_anything: bool = remainder < picked_up_quantity
	
	if picked_up_anything:
		# TODO despawn or decrement world item on the server
		pass
			
	_send_inventory_snapshot_to_owner()
#endregion
	
#region Replication
func _send_inventory_snapshot_to_owner() -> void:
	var owner_peer_id: int = player.get_multiplayer_authority()
	var snapshot: Array = inventory_container.create_network_snapshot()
	rpc_id(
		owner_peer_id,
		"client_receive_inventory_snapshot",
		snapshot
	)
	
@rpc("authority", "reliable")
func client_receive_inventory_snapshot(snapshot: Array) -> void:
	inventory_container.apply_network_snapshot(snapshot)
#endregion
	
