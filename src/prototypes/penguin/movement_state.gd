extends Node
class_name MovementStateMachine


@export var initial_state: PenguinState

var current_state: PenguinState
var player: Penguin

var states := {}


func init(p_player: Penguin) -> void:
	player = p_player

	for child in get_children():
		if child is PenguinState:
			child.player = player
			child.state_machine = self

			states[child.name] = child

	current_state = initial_state

	if current_state:
		current_state.enter()


func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func change_state(state_name: StringName) -> void:
	var new_state: PenguinState = states.get(state_name)

	if new_state == null:
		push_warning("State not found: " + String(state_name))
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
