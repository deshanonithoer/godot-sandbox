class_name RunState
extends MovementState
func physics_update(delta):
	if not Input.is_action_pressed("sprint"):
		player.fsm.change_state(StateEnum.Value.WALK)
		return

	super.physics_update(delta)
