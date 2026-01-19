class_name StateMachine
extends Node

var entity
var current_state
var states := {}

func change_state(key):
	if not states.has(key):
		push_warning("State not found: %s" % key)
		return

	if current_state:
		current_state.exit(states[key])

	var prev = current_state
	current_state = states[key]
	current_state.enter(prev)

func handle_input(event):
	if current_state:
		current_state.handle_input(event)

func update(delta):
	if current_state:
		current_state.update(delta)

func physics_update(delta):
	if current_state:
		current_state.physics_update(delta)
