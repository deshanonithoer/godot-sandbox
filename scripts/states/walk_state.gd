class_name WalkState
extends MovementState

func enter(_prev: PlayerState) -> void:
	move_speed_multiplier = 1.0
	animation_state = StateEnum.Value.WALK
		
func physics_update(delta):		
	if player.wants_sprint:
		player.fsm.change_state(StateEnum.Value.RUN)
		return

	super.physics_update(delta)
	
