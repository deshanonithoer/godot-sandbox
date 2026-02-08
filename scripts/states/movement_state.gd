class_name MovementState
extends PlayerState

@onready var player_animations: PlayerAnimation = %PlayerAnimations

@export var speed := 200;
@export var move_speed_multiplier := 1.0;
var animation_state: StateEnum.Value

func physics_update(_delta):
	if player.consume_attack() and can_attack():
		player.fsm.change_state(StateEnum.Value.ATTACK)
		return
	
	if player.wants_sprint:
		player.fsm.change_state(StateEnum.Value.RUN)
	
	if player.input_direction == Vector2.ZERO:
		player.fsm.change_state(StateEnum.Value.IDLE)
		return
		
	player.velocity = player.input_direction * speed * move_speed_multiplier
	player.move_and_slide()
	
	var resolved := player.resolve_direction(player.input_direction)
	player.last_resolved_direction = resolved
	
	var walk_animation = player_animations.animations[resolved][animation_state]
	player.sprite.play(walk_animation)
