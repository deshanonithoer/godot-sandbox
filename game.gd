extends Node2D

@onready var inventory_window: InventoryUI = %InventoryWindow
@onready var multiplayer_menu: Node2D = %MultiplayerMenu

#region Signal Connections
func _on_menu_host_game(nick_name: String) -> void:
	NetworkManager.host_game(nick_name)
	multiplayer_menu.hide()
	inventory_window.show()
	
func _on_menu_join_game(address: String, port: String, nick_name: String) -> void:
	NetworkManager.join_game(address, port, nick_name)
	multiplayer_menu.hide()
	inventory_window.show()
#endregion
