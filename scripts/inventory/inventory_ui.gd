class_name InventoryUI
extends Node

@onready var players: Node = %Players

@export var slot_ui_scene: PackedScene
@export var backpack_slot_count: int = 15
@export var hotbar_slot_count: int = 5

@onready var backpack_grid: HBoxContainer = $Panel/VBoxContainer/BackpackGrid
@onready var hotbar_row: HBoxContainer = $Panel/VBoxContainer/HotbarRow

var local_player: Node = null

var inventory_controller: InventoryController
var inventory_container: InventoryContainer
var hotbar_references: HotbarSlotReferences

var backpack_slot_uis: Array[SlotUI] = []
var hotbar_slot_uis: Array[SlotUI] = []

# Save selected source slot index
var selected_source_inventory_slot_index: int = -1

# Specific to split logic
var is_waiting_for_split_target: bool = false
var split_source_inventory_slot_index: int = -1
var split_quantity: int = 0

func _ready() -> void:
	players.child_entered_tree.connect(_on_players_child_entered_tree)	

func _on_players_child_entered_tree(new_child: Player) -> void:
	_try_bind_to_local_player()

func _try_bind_to_local_player() -> void:
	if local_player != null:
		return

	var local_peer_id: int = multiplayer.get_unique_id()

	for child in players.get_children():
		if child is Player and child.get_multiplayer_authority() == local_peer_id:
			local_player = child
			_bind_ui_to_player(local_player)
			return

func _bind_ui_to_player(player: Player) -> void:
	inventory_controller = player.get_node("Inventory/InventoryController")
	inventory_container = inventory_controller.inventory_container
	hotbar_references = inventory_controller.hotbar_references
	
	_build_ui()
	
	# Refresh in case of snapshot updates
	inventory_container.inventory_changed.connect(_on_inventory_changed)
	hotbar_references.hotbar_changed.connect(_on_hotbar_changed)
	
	_refresh_all_slots()
	
# Swithing hotbar by using the numbers on the keyboard
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		_handle_hotbar_number_keys(key_event)
		

func _handle_hotbar_number_keys(key_event: InputEventKey) -> void:
	var keycode := key_event.keycode
	var hotbar_index := -1

	if keycode >= KEY_1 and keycode <= KEY_9:
		hotbar_index = int(keycode - KEY_1)
	elif keycode == KEY_0:
		hotbar_index = 5

	if hotbar_index >= 0 and hotbar_index < hotbar_slot_count:
		hotbar_references.set_selected_hotbar_slot_index(hotbar_index)
		_refresh_hotbar_highlights()
		
func _build_ui() -> void:
	for child in backpack_grid.get_children():
		child.queue_free()
		
	for child in hotbar_row.get_children():
		child.queue_free()
		
	backpack_slot_uis.clear()
	hotbar_slot_uis.clear()
	
	for inventory_slot_index in range(backpack_slot_count):
		var slot_ui := slot_ui_scene.instantiate() as SlotUI
		slot_ui.slot_index = inventory_slot_index
		slot_ui.left_click.connect(_on_backpack_slot_left_clicked)
		slot_ui.right_click.connect(_on_backpack_slot_right_clicked)
		
		backpack_grid.add_child(slot_ui)
		backpack_slot_uis.append(slot_ui)
		
	for hotbar_slot_index in range(hotbar_slot_count):
		var slot_ui := slot_ui_scene.instantiate() as SlotUI
		slot_ui.slot_index = hotbar_slot_index
		slot_ui.left_click.connect(_on_hotbar_slot_left_clicked)
		slot_ui.right_click.connect(_on_hotbar_slot_right_clicked)
		
		hotbar_row.add_child(slot_ui)
		hotbar_slot_uis.append(slot_ui)
		
	_refresh_hotbar_highlights()
	
func _on_inventory_changed(_snapshot: Array) -> void:
	_refresh_all_slots()
	
func _on_hotbar_changed() -> void:
	_refresh_all_slots()
	
func _refresh_all_slots() -> void:
	_refresh_backpack_visuals()
	_refresh_hotbar_visuals()
	_refresh_backpack_highlights()
	_refresh_hotbar_highlights()
	
func _refresh_backpack_visuals() -> void:
	for inventory_slot_index in range(backpack_slot_uis.size()):
		var slot_ui = backpack_slot_uis[inventory_slot_index] as SlotUI
		var stack := inventory_container.get_stack_in_slot(inventory_slot_index)
		
		if stack == null or stack.is_empty():
			continue
			
		var item_definition: ItemDefinition = inventory_container.item_definitions_by_id.get(stack.item_id, null)
		slot_ui.set_stack_visual(item_definition, stack.quantity)
		
func _refresh_hotbar_visuals() -> void:
	for hotbar_slot_index in range(hotbar_slot_uis.size()):
		var slot_ui = hotbar_slot_uis[hotbar_slot_index] as SlotUI
		
		var inventory_slot_index: int = hotbar_references.hotbar_to_inventory_slot_map[hotbar_slot_index]
		var stack := inventory_container.get_stack_in_slot(inventory_slot_index)
		
		if stack == null or stack.is_empty():
			continue
		
		var item_definition: ItemDefinition = inventory_container.item_definitions.get(stack.item_id, null)
		slot_ui.set_stack_visual(item_definition, stack.quantity)
		
func _refresh_backpack_highlights() -> void:
	for inventory_slot_index in range(backpack_slot_uis.size()):
		var slot_ui := backpack_slot_uis[inventory_slot_index]
		
		var is_selected_source := inventory_slot_index == selected_source_inventory_slot_index
		var is_selected_split_source := is_waiting_for_split_target and inventory_slot_index == split_source_inventory_slot_index
		
		slot_ui.set_highlighted(is_selected_source or is_selected_split_source)
		
func _refresh_hotbar_highlights() -> void:
	for hotbar_slot_index in range(hotbar_slot_uis.size()):
		var slot_ui := hotbar_slot_uis[hotbar_slot_index]
		var is_selected_hotbar := hotbar_slot_index == hotbar_references.selected_hotbar_slot_index
		slot_ui.set_highlighted(is_selected_hotbar)
		
#region Backpack slot interactions

func _on_backpack_slot_left_clicked(slot_ui: SlotUI) -> void:
	var clicked_inventory_slot_index: int = slot_ui.slot_index
	
	# In case we are still in split mode, try to split into clicked slot
	if is_waiting_for_split_target:
		_try_place_split_into_target(clicked_inventory_slot_index)
		return
		
	# First click selects a source slot (must contain something)
	if selected_source_inventory_slot_index == -1:
		var clicked_stack := inventory_container.get_stack_in_slot(clicked_inventory_slot_index)
		if clicked_stack == null or clicked_stack.is_empty():
			return
			
		selected_source_inventory_slot_index = clicked_inventory_slot_index
		_refresh_backpack_highlights()
		return
		
	# Second click
	var source_inventory_slot_index := selected_source_inventory_slot_index
	var target_inventory_slot_index := clicked_inventory_slot_index
	
	selected_source_inventory_slot_index = -1
	_refresh_backpack_highlights()
	
	inventory_controller.request_move_inventory_slot(
		source_inventory_slot_index, 
		target_inventory_slot_index
	)

func _on_backpack_slot_right_clicked(slot_ui: SlotUI) -> void:
	# Right-click a stack, then left-click an empty slot to place half
	var clicked_inventory_slot_index: int = slot_ui.slot_index
	var clicked_stack = inventory_container.get_stack_in_slot(clicked_inventory_slot_index)
	
	if clicked_stack == null or clicked_stack.is_empty():
		return
	
	if clicked_stack.quantity < 2:
		return
		
	is_waiting_for_split_target = true
	split_source_inventory_slot_index = clicked_inventory_slot_index
	split_quantity = clicked_stack.quantity / 2
	
	selected_source_inventory_slot_index = -1
	_refresh_backpack_highlights()
	
func _try_place_split_into_target(target_inventory_slot_index: int) -> void:
	if not is_waiting_for_split_target:
		return
		
	# Only allow splitting into empty slots 
	var target_stack := inventory_container.get_stack_in_slot(target_inventory_slot_index)
	if target_stack != null and not target_stack.is_empty():
		# Force split mode on until user clicks again
		return
		
	var source_inventory_slot_index := split_source_inventory_slot_index
	var quantity_to_split := split_quantity
	
	is_waiting_for_split_target = false
	split_source_inventory_slot_index = -1
	split_quantity = 0
	_refresh_backpack_highlights()
	
	inventory_controller.request_split_inventory_slot(
		source_inventory_slot_index, 
		quantity_to_split,
		target_inventory_slot_index
	)	
#endregion

#region Hotbar interactions

func _on_hotbar_slot_left_clicked(slot_ui: SlotUI) -> void:
	var clicked_hotbar_slot_index: int = slot_ui.slot_index
	hotbar_references.set_selected_hotbar_slot_index(clicked_hotbar_slot_index)
	inventory_controller.request_use_selected_hotbar_item()
	_refresh_hotbar_highlights()
	
func _on_hotbar_slot_right_clicked(slot_ui: SlotUI) -> void:
	pass
	
#endregion
