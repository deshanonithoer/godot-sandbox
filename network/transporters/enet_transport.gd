class_name EnetTransport
extends NetworkTransport

const DEFAULT_PORT := 8910
const DEFAULT_ADDRESS := "127.0.0.1"

func setup(multiplayer_api: MultiplayerAPI) -> void:
	super.setup(multiplayer_api)

func connect_transport_signals() -> void:
	pass

func host_game(port: int = DEFAULT_PORT) -> void:
	var enet := ENetMultiplayerPeer.new()
	var err := enet.create_server(port, NetworkManager.MAX_PLAYERS)
	
	if err != OK:
		push_error("Failed to create ENET server: %s" % err)
		return
		
	peer = enet
	mp.multiplayer_peer = peer
	
	NetworkManager.connect_multiplayer_signals()
	NetworkManager.peer_connected.emit(mp.get_unique_id())
	
func join_game(address: String = DEFAULT_ADDRESS, port: int = DEFAULT_PORT) -> void:
	var enet := ENetMultiplayerPeer.new()
	var err := enet.create_client(address, port)
	
	if err != OK: 
		push_error("Failed to connect to ENET server: %s" % err)
		return
		
	peer = enet
	mp.multiplayer_peer = peer
	NetworkManager.connect_multiplayer_signals()
