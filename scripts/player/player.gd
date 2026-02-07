class_name Player
extends Entity

@onready var walk_state: WalkState = $Scripts/StateMachine/WalkState
@onready var attack_state: AttackState = $Scripts/StateMachine/AttackState
@onready var run_state: RunState = $Scripts/StateMachine/RunState
@onready var movement_state: MovementState = $Scripts/StateMachine/MovementState
@onready var idle_state: IdleState = $Scripts/StateMachine/IdleState
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: StateMachine = %StateMachine

#region Player state management

var last_direction := Vector2.DOWN
var last_resolved_direction: DirectionEnum.Value = DirectionEnum.Value.DOWN

@export_storage var input_direction := Vector2.ZERO
@export_storage var wants_sprint := false
@export_storage var wants_attack := false
@export_storage var attack_direction := Vector2.ZERO

func _ready():
	fsm.entity = self
	fsm.states = {
		StateEnum.Value.IDLE: idle_state,
		StateEnum.Value.WALK: walk_state,
		StateEnum.Value.RUN: run_state,
		StateEnum.Value.ATTACK: attack_state,
	}

	for state in fsm.states.values():
		state.player = self

	fsm.change_state(StateEnum.Value.IDLE)
	
func _unhandled_input(_event):
	# Only the locally controlled player should ever read hardware input.
	# This prevents remote players and the server from reacting to local input.
	if not _is_local_player():
		return

	# Gather input locally (keyboard / controller).
	input_direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	
	attack_direction = (self.get_global_mouse_position() - self.global_position).normalized()
	wants_sprint = Input.is_action_pressed("sprint")
	wants_attack = Input.is_action_pressed("attack")

	# Send input intent to the authority (server).
	# Using unreliable RPC because this is high-frequency data.
	_send_input.rpc(
		input_direction, 
		wants_sprint, 
		wants_attack, 
		attack_direction
	)
	
func _is_local_player() -> bool:
	return multiplayer.get_unique_id() == get_multiplayer_authority()
	
@rpc("any_peer", "unreliable")
func _send_input(
	dir: Vector2, 
	sprint: bool, 
	attack: bool, 
	attack_dir: Vector2
):
	input_direction = dir
	wants_sprint = sprint
	wants_attack = attack
	attack_direction = attack_dir
	
func _process(delta):
	fsm.update(delta)

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	fsm.physics_update(delta)
	
#endregion

#region Public player helper methods
func consume_attack() -> bool:
	if wants_attack:
		wants_attack = false
		return true
	return false
	
func _resolve_direction(dir: Vector2) -> DirectionEnum.Value:
	# Horizontal
	if abs(dir.x) > abs(dir.y):
		return DirectionEnum.Value.LEFT if dir.x < 0 else DirectionEnum.Value.RIGHT

	# Vertical
	return DirectionEnum.Value.UP if dir.y < 0 else DirectionEnum.Value.DOWN
	
#endregion
