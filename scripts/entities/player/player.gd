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

func _ready():		
	fsm.entity = self
	fsm.states = {
		StateEnum.Value.IDLE: idle_state,
		StateEnum.Value.WALK: walk_state,
		StateEnum.Value.RUN:  run_state,
		StateEnum.Value.ATTACK: attack_state,
	}

	for state in fsm.states.values():
		state.player = self

	fsm.change_state(StateEnum.Value.IDLE)
	
func _input(event):
	fsm.handle_input(event)

func _process(delta):
	fsm.update(delta)

func _physics_process(delta):
	fsm.physics_update(delta)
	
#endregion

#region Public player helper methods

func _resolve_direction(dir: Vector2) -> DirectionEnum.Value:
	# Horizontal
	if abs(dir.x) > abs(dir.y):
		return DirectionEnum.Value.LEFT if dir.x < 0 else DirectionEnum.Value.RIGHT

	# Vertical
	return DirectionEnum.Value.UP if dir.y < 0 else DirectionEnum.Value.DOWN
	
#endregion
