class_name IdleState
extends PlayerState
@onready var player_animations: PlayerAnimation = %PlayerAnimations

func enter(_prev):
	player.velocity = Vector2.ZERO
	player.sprite.play(
		player_animations.animations[player.last_resolved_direction][StateEnum.Value.IDLE]
	)

func physics_update(_delta):
	if Input.is_action_just_pressed("sprint"):
		player.fsm.change_state(StateEnum.Value.RUN)
		
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	
	if direction != Vector2.ZERO:
		player.fsm.change_state(StateEnum.Value.WALK)
