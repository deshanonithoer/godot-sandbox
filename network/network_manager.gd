extends Node

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

const MAX_PLAYERS = 16

var is_joining := false
var transporter: NetworkTransport

func _ready():
	transporter = EnetTransport.new() as NetworkTransport
	transporter.setup(multiplayer)
	transporter.connect_transport_signals()

func host_game() -> void:
	transporter.host_game()
	
func join_game(address: String, port: String) -> void:
	is_joining = true
	transporter.join_game(address, port.to_int())

func connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)

func on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)
	
func cleanup_peer() -> void:
	transporter.cleanup()
	
