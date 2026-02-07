extends Node

signal lobby_created(lobby_id: int)
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

const MAX_PLAYERS = 16

var lobby_id := 0
var is_joining := false
var transporter: NetworkTransport

func _ready():
	#transporter = SteamTransport.new() as NetworkTransport
	transporter = EnetTransport.new() as NetworkTransport
	transporter.setup(multiplayer)
	transporter.connect_transport_signals()

func host_game() -> void:
	transporter.host_game()
	
func join_game(address: String, port: String) -> void:
	is_joining = true
	transporter.join_game(address, port.to_int())

func connect_multiplayer_signals() -> void:
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		return
		
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)
	
func cleanup_peer() -> void:
	transporter.cleanup()
	lobby_id = 0
	
