extends Node
class_name State

var state_name : String

var machine : StateMachine

# Called when the state is entered
func enter():
	pass

# Called every frame while the state is active
func process_state(delta):
	pass

# Called when the state is exited
func exit():
	machine.previous_state = str(state_name)
