class_name SlotUI
extends Control

signal left_click(slot_ui: SlotUI)
signal right_click(slot_ui: SlotUI)

@export var slot_index: int = -1

 # These are required
@onready var icon_texture: TextureRect = $TextureRect
@onready var quantity_label: Label = $QuantityLabel
@onready var highlight_panel: Panel = $HighlightPanel

func set_highlighted(is_highlighted: bool) -> void:
	highlight_panel.visible = is_highlighted

func set_stack_visual(item_definition: ItemDefinition, quantity: int) -> void:
	if item_definition == null or quantity <= 0:
		icon_texture.texture = null
		quantity_label.text = ""
		return
		
	icon_texture.texture = item_definition.icon_texture
	quantity_label.text = str(quantity) if quantity > 1 else ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			left_click.emit(self)
			accept_event()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			right_click.emit(self)
			accept_event()
