extends State

var parent : Player

func enter():
	print("Entered WALK State")
	parent.animated_sprite.play("WALK")
	
func process_state(delta):
	parent.apply_gravity(delta)
	
	if parent.atk_state_machine.get_current_state() == "NO_ATK":
		
		parent.flip_sprite()
	
		parent.apply_acceleration(parent.walk_spd, parent.walk_accel, delta)
		
		if parent.check_horizontal_input() == 0:
			machine.change_state("IDLE")
			return
			
		if Input.is_action_just_pressed("roll")  || parent.buffer_roll:
			SignalBus.emit_signal("send_stamina_cost", parent.roll_cost)
			if parent.stamina != 0 && parent.stamina - parent.roll_cost >= 0:
				machine.change_state("ROLL")
				return
		
		if Input.is_action_just_pressed("jump") || parent.buffer_jump:
			if parent.buffer_jump:
				print("Buffer_JUMP")
			machine.change_state("JUMP")
			return
		
		if Input.is_action_pressed("crouch") && !parent.can_fall_through && parent.is_on_floor():
			machine.change_state("CROUCH")
			return
		
		if parent.velocity.y > 0 && !parent.is_on_floor() && !machine.previous_state == "ROLL":  #fixes when you roll and you fall through one way platforms
			machine.change_state("FALL")
			return
