extends State

var parent : Player

func enter():
	print("ENTER CLIMB")
	parent.animated_sprite.play("CLIMB")
	parent.velocity.x = 0
	parent.velocity.y = 0
	
func process_state(delta):
	parent.apply_acceleration(parent.climb_speed, parent.climb_accel, delta)
	if !parent.climbable_detector.is_colliding():
		machine.change_state("FALL")
		return
		
	if Input.is_action_just_pressed("jump"):
		if parent.check_horizontal_input() != 0:
			parent.velocity.x = parent.check_horizontal_input() * parent.climb_jump_strength
		machine.change_state("JUMP")
		return
		
	if parent.check_vertical_input() == 0:
		parent.animated_sprite.pause()
	else:
		parent.animated_sprite.play("CLIMB")
		return
