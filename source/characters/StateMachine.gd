extends Node
class_name StateMachine

var current_state: State
var previous_state : String

func init(parent: Node, machine: StateMachine) -> void:
	for child in get_children():
		if child is State:
			child.parent = parent
			child.machine = machine
		else:
			print("Child node is not a State: ", child)

func change_state(state_name: String):
	if current_state:
		current_state.exit()

	# Find the new state node
	var new_state = get_node(state_name)
	if new_state and new_state is State:
		current_state = new_state
		current_state.state_name = state_name
		current_state.enter()
	else:
		print("State not found or invalid: " + state_name)
		
func get_current_state() -> String:
	return(current_state.state_name)

func process_state(delta):
	if current_state:
		current_state.process_state(delta)
