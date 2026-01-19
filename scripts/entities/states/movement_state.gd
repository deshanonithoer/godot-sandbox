class_name MovementState
extends PlayerState

@onready var player_animations: PlayerAnimation = %PlayerAnimations

@export var speed := 200;
@export var move_speed_multiplier := 1.2;
var animation_state: StateEnum.Value

func physics_update(_delta):
	if Input.is_action_pressed("sprint"):
		player.fsm.change_state(StateEnum.Value.RUN)
		
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	
	if direction == Vector2.ZERO:
		player.fsm.change_state(StateEnum.Value.IDLE)
		return
		
	player.velocity = direction * speed * move_speed_multiplier
	player.move_and_slide()
	
	var resolved := player._resolve_direction(direction)
	player.last_resolved_direction = resolved
	
	var walk_animation = player_animations.animations[resolved][animation_state]
	player.sprite.play(walk_animation)
