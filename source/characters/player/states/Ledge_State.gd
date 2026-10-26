extends State

var parent : Player

func enter():
	print("Entered Ledge State")
	parent.hurtbox_collision_shape.disabled = true
	parent.ledge_hurtbox_collision_shape.disabled = false
	parent.animated_sprite.play("LEDGE_GRAB")
	parent.velocity.y = 0

func process_state(delta):
	if Input.is_action_just_pressed("jump"):
		parent.ledge_jump = true
		machine.change_state("JUMP")

func exit():
	machine.previous_state = str(state_name)
	parent.grab_ledge = false
	parent.hurtbox_collision_shape.disabled = false
	parent.ledge_hurtbox_collision_shape.disabled = true
