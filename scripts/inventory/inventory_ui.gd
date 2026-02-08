class_name InventoryUI
extends Node

@export var slot_ui_scene: PackedScene
@export var backpack_slot_count: int = 15
@export var hotbar_slot_count: int = 5

# This class is abstract until below is linked to player controller
@export var inventory_controller_path: NodePath

@onready var backpack_grid: GridContainer = $BackpackContainer
@onready var hotbar_row: GridContainer = $HotbarContainer

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

#func _ready() -> void:
	#inventory_controller = get_node(inventory_controller_path) as InventoryController
	#if inventory_controller == null:
		#push_error("InventoryWindow: inventory_controller_path is not set or invalid")
		#return
	#
	#inventory_container = inventory_controller.inventory_container
	#hotbar_references = inventory_controller.hotbar_references
	#
	#_build_ui()
	#
	## Refresh in case of snapshot updates
	#inventory_container.inventory_changed.connect(_on_inventory_changed)
	#hotbar_references.hotbar_changed.connect(_on_hotbar_changed)
	#
	#_refresh_all_slots()
	#
## Swithing hotbar by using the numbers on the keyboard
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.echo:
		#var key_event := event as InputEventKey
		## _handle_hotbar_number_keys(key_event)
