class_name InventoryController
extends Node

@export var item_definitions_by_id: Dictionary = {}

@onready var player: Node = get_parent()
@onready var inventory_container: InventoryContainer = player.get_node("InventoryContainer")
@onready var hotbar_references: HotbarSlotReferences = player.get_node("HotbarSlotReferences")

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
		
	var requesting_peer_id: int = multiplayer.get_remote_sender_id()
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
		_:
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
	
