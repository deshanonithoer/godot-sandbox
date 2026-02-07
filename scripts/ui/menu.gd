extends Node2D

@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var ip_address_prompt: LineEdit = $IPAddressPrompt
@onready var port_prompt: LineEdit = $PortPrompt
@onready var name_prompt: LineEdit = $NamePrompt

signal host_game(player_name: String)
signal join_game(address: String, port: String, nick_name: String)

func _on_host_button_pressed() -> void:
	var nick_name = name_prompt.text
	host_game.emit(nick_name)

func _on_join_button_pressed() -> void:
	var ip_address = ip_address_prompt.text
	var port = port_prompt.text
	var nick_name = name_prompt.text
	
	if port.length() <= 0:
		return
		
	join_game.emit(
		ip_address, 
		port, 
		nick_name
	)

func _on_lobby_id_prompt_text_changed(new_text: String) -> void:
	if new_text.length() <= 0:
		return
		
	join_button.disabled = false
	
