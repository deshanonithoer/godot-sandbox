class_name ItemDefinition
extends Resource

@export var id: StringName
@export var name: String = ""
@export var icon_texture: Texture2D
@export var max_stack_size: int = 1

enum ItemCategory {
	TOOL,
	WEAPON,
	SEED,
	CROP,
	MATERIAL,
	CONSUMABLE
}
@export var category: ItemCategory = ItemCategory.MATERIAL

enum UseBehaviour {
	NONE,
	PLACE_TILE,
	PLANT_SEED,
	SWING_TOOL,
	CONSUME
}
@export var use_behaviour: UseBehaviour = UseBehaviour.NONE

@export var damage_amount: int = 0
@export var heal_amount: int = 0
@export var placeable_scene: PackedScene
