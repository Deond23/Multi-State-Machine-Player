extends State

var parent : Player

func enter():
	print("Entered Idle State")
	if !parent.animation_player.is_playing() && !parent.animated_sprite.animation == "SHIELD" :
		parent.animated_sprite.play("IDLE")
		if !parent.invincible:
			parent.hurtbox_collision_shape.disabled = false
		parent.scaled = false
		parent.air_atcks = 0

func process_state(delta):
	parent.apply_gravity(delta)
	
	if parent.atk_state_machine.get_current_state() == "NO_ATK":
		
		parent.apply_friction(delta)
		
		if parent.check_horizontal_input() != 0:
			machine.change_state("WALK")
			return
		
		if Input.is_action_just_pressed("roll") || parent.buffer_roll:
			SignalBus.emit_signal("send_stamina_cost", parent.roll_cost)
			if parent.stamina != 0 && parent.stamina - parent.roll_cost >= 0:
				machine.change_state("ROLL")
				return
				
		if Input.is_action_just_pressed("jump") || parent.buffer_jump:
			if parent.buffer_jump:
				print("Buffer_JUMP")
			machine.change_state("JUMP")
			return
			
		if Input.is_action_pressed("crouch") && parent.is_on_floor():
				machine.change_state("CROUCH")
				return
			
		if parent.velocity.y > 0 && !parent.is_on_floor() && !machine.previous_state == "ROLL":  #fixes when you roll and you fall through one way platforms
				machine.change_state("FALL")
				return
