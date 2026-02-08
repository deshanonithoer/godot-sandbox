class_name HurtState
extends PlayerState

@onready var player_animations: PlayerAnimation = %PlayerAnimations

var direction: DirectionEnum

func enter(_prev: PlayerState) -> void:
	var hurt_animation = player_animations.animations[player.last_resolved_direction][StateEnum.Value.HURT]
	player.sprite.play(hurt_animation)
	
func _animation_compeleted():
	player.fsm.change_state(StateEnum.Value.IDLE)
