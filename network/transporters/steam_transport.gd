#class_name SteamTransport
#extends NetworkTransport
#
#const APP_ID = 480
#const LOBBY_TYPE = Steam.LOBBY_TYPE_PUBLIC
	#
#func setup(multiplayer_api: MultiplayerAPI) -> void:
	#var result = Steam.steamInit(APP_ID, true)
	#print_debug("Steam initialized:", result)
	#Steam.initRelayNetworkAccess()
	#super.setup(multiplayer_api)
#
#func host_game() -> void:
	#Steam.createLobby(LOBBY_TYPE, NetworkManager.MAX_PLAYERS)
	#
#func join_game(address: String, port: int = 0) -> void:
	#Steam.joinLobby(port)
#
#func connect_transport_signals() -> void:
	#Steam.lobby_created.connect(_on_lobby_created)
	#Steam.lobby_joined.connect(_on_lobby_joined)
	#
#func _on_lobby_created(result: int, created_lobby_id: int) -> void:
	#if result != Steam.Result.RESULT_OK:
		#push_error("Could not create lobby!")
		#return
#
	#NetworkManager.lobby_id = created_lobby_id
	#_create_host_peer()
	#NetworkManager.lobby_created.emit(created_lobby_id)
	#DisplayServer.clipboard_set(str(created_lobby_id))
	#
#func _on_lobby_joined(joined_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	#if !NetworkManager.is_joining:
		#return
	#NetworkManager.is_joining = false
#
	#if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		#push_error(response)
		#return
#
	#NetworkManager.lobby_id = joined_lobby_id
	#_create_client_peer(Steam.getLobbyOwner(joined_lobby_id))
#
#func _create_host_peer() -> void:
	#peer = SteamMultiplayerPeer.new()
	#peer.server_relay = true
	#peer.create_host()
	#mp.multiplayer_peer = peer
	#
	#NetworkManager.connect_multiplayer_signals()
	#NetworkManager.peer_connected.emit(1)
#
#func _create_client_peer(host_steam_id: int) -> void:
	#peer = SteamMultiplayerPeer.new()
	#peer.server_relay = true
	#peer.create_client(host_steam_id)
	#mp.multiplayer_peer = peer
	#NetworkManager.connect_multiplayer_signals()
