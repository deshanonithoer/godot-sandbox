class_name NetworkTransport
extends RefCounted

var peer: MultiplayerPeer
var mp: MultiplayerAPI

func setup(multiplayer_api: MultiplayerAPI):
	mp = multiplayer_api

func host_game() -> void:
	push_error("Not implemented")
	
func join_game(address: String, port: int) -> void:
	push_error("Not implemented")

func connect_transport_signals() -> void:
	push_error("Not implemented")
	
func cleanup() -> void:
	if mp.multiplayer_peer:
		mp.multiplayer_peer = null

	if peer:
		peer.close()
	peer = null

func _create_host_peer() -> void:
	push_error("Not implemented")
	
func _create_client_peer(host_steam_id: int) -> void:
	push_error("Not implemented")
