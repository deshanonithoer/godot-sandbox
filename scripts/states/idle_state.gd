class_name IdleState
extends PlayerState
@onready var player_animations: PlayerAnimation = %PlayerAnimations

func enter(_prev):
	player.velocity = Vector2.ZERO
	player.sprite.play(
		player_animations.animations[player.last_resolved_direction][StateEnum.Value.IDLE]
	)

func physics_update(_delta):	
	if player.consume_attack() and can_attack():
		player.fsm.change_state(StateEnum.Value.ATTACK)
		return
			
	if player.wants_sprint:
		player.fsm.change_state(StateEnum.Value.RUN)
	
	if player.input_direction != Vector2.ZERO:
		player.fsm.change_state(StateEnum.Value.WALK)
