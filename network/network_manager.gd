extends Node

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

const SERVER_PEER_ID = 1
const MAX_PLAYERS = 16

var is_joining := false
var transporter: NetworkTransport
var nick_name: String
var nick_by_peer := {}

func _ready():
	transporter = EnetTransport.new() as NetworkTransport
	transporter.setup(multiplayer)
	transporter.connect_transport_signals()

func host_game(player_name: String) -> void:
	nick_name = player_name
	nick_by_peer[1] = player_name
	transporter.host_game()
	
func join_game(address: String, port: String, player_name: String) -> void:
	is_joining = true
	nick_name = player_name
	transporter.join_game(address, port.to_int())
		
	if !multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server() -> void:
	_register_nick.rpc_id(1, nick_name)
	
func connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(peer_id: int) -> void:
	_register_nick.rpc_id(1, NetworkManager.nick_name)

func on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)
	
func cleanup_peer() -> void:
	transporter.cleanup()
	
@rpc("any_peer", "call_local", "reliable")
func _register_nick(nick: String) -> void:
	if !multiplayer.is_server():
		return
	
	var sender := multiplayer.get_remote_sender_id()
	nick_by_peer[sender] = nick
	peer_connected.emit(sender)
	
	
