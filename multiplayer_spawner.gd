extends Node

var target_node: Node
@export var player_scene: PackedScene
@onready var spawn_point: Marker2D = %SpawnPoint

func set_target_node(target: Node) -> void:
	target_node = target
	
func _enter_tree() -> void:
	NetworkManager.peer_connected.connect(_spawn_player)
	NetworkManager.peer_disconnected.connect(_despawn_player)
	
func _spawn_player(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
		
	if target_node == null:
		return
		
	if target_node.has_node(str(peer_id)):
		return
		
	var player := player_scene.instantiate()
	player.name = str(peer_id)
	target_node.add_child(player)
	player.global_position = spawn_point.global_position
	player.set_multiplayer_authority(1)
	
func _despawn_player(peer_id: int) -> void:
	if not target_node.has_node(str(peer_id)):
		return
		
	target_node.get_node(str(peer_id)).queue_free()
