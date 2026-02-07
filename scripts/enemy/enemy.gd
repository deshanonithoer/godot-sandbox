class_name Enemy
extends Entity

@onready var fsm: StateMachine = $Scripts/StateMachine

#region Player state management

var last_direction := Vector2.DOWN
var last_resolved_direction: DirectionEnum.Value = DirectionEnum.Value.DOWN

func _ready():
	fsm.entity = self
	fsm.states = {}

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
