extends Node2D



#region Signal Connections
func _on_menu_host_game() -> void:
	NetworkManager.host_game()
	%Menu.hide()
	
func _on_menu_join_game(address: String, port: String) -> void:
	NetworkManager.join_game(address, port)
	%Menu.hide()
#endregion
