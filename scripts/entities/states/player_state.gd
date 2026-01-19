class_name PlayerState
extends Node

var player: Player

func can_attack() -> bool:
	return true
	
func enter(_prev: PlayerState) -> void:
	pass
	
func exit(_next: PlayerState) -> void:
	pass
	
func handle_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton \
	and _event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and _event.pressed:
		if player.fsm.current_state != player.fsm.states[StateEnum.Value.ATTACK]:
			player.fsm.change_state(StateEnum.Value.ATTACK)
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
