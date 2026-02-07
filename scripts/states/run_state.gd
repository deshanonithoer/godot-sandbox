class_name RunState
extends MovementState

func enter(_prev: PlayerState) -> void:
	move_speed_multiplier = 1.2
	animation_state = StateEnum.Value.RUN
	
func physics_update(delta):
	if not player.wants_sprint:
		player.fsm.change_state(StateEnum.Value.WALK)
		return

	super.physics_update(delta)
