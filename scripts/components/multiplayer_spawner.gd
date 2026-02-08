extends MultiplayerSpawner

@export var player_scene: PackedScene

@onready var players: Node = %Players
@onready var spawn_point: Marker2D = %SpawnPoint

func _ready() -> void:
	spawn_path = get_path_to(players)

	if player_scene:
		add_spawnable_scene(player_scene.resource_path)

	NetworkManager.peer_connected.connect(_on_peer_connected)
	NetworkManager.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id: int) -> void:
	if !multiplayer.is_server():
		return

	_spawn_player_server(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	if !multiplayer.is_server():
		return

	var player := players.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _spawn_player_server(peer_id: int) -> void:
	if players == null:
		push_error("Players node not found (%Players).")
		return

	var player_name := str(peer_id)
	if players.has_node(player_name):
		return

	var player := player_scene.instantiate()
	var nick = NetworkManager.nick_by_peer.get(peer_id, str(peer_id))
	player.player_name = str(nick)
	player.name = player_name
	player.id = peer_id

	player.set_multiplayer_authority(NetworkManager.SERVER_PEER_ID, true)
	
	players.add_child(player)

	if player is Node2D and spawn_point:
		player.global_position = spawn_point.global_position
