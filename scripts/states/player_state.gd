class_name PlayerState
extends Node

var player: Player

func can_attack() -> bool:
	return true
	
func enter(_prev: PlayerState) -> void:
	pass
	
func exit(_next: PlayerState) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
