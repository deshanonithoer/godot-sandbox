extends Node2D

#region Signal Connections
func _on_menu_host_game(nick_name: String) -> void:
	NetworkManager.host_game(nick_name)
	%Menu.hide()
	
func _on_menu_join_game(address: String, port: String, nick_name: String) -> void:
	NetworkManager.join_game(address, port, nick_name)
	%Menu.hide()
#endregion
