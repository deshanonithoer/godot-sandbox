extends Node2D

@onready var players: Node = $Players	
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready() -> void:
	multiplayer_spawner.set_target_node(players)

#region Signal Connections
func _on_menu_host_game() -> void:
	NetworkManager.host_game()
	%Menu.hide()
	
func _on_menu_join_game(address: String, port: String) -> void:
	NetworkManager.join_game(address, port)
	%Menu.hide()
#endregion
