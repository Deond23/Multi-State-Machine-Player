extends State

var parent : Player

func enter():
	print("Entered CW State")
	parent.animated_sprite.play("CROUCH_WALK")
	parent.collision_shape.disabled = true
	parent.crouch_collision_shape.disabled = false
	parent.hurtbox_collision_shape.disabled = true
	if !parent.invincible:
		parent.crouch_hurtbox_collision_shape.disabled = false

func process_state(delta):
	parent.flip_sprite()
	parent.apply_gravity(delta)
	parent.apply_acceleration(parent.crouch_walk_spd, parent.crouch_accel, delta)
	
	if !Input.is_action_pressed("crouch") && !parent.crouch_ceiling_detector.is_colliding() && !parent.crouch_ceiling_detector_2.is_colliding():
			machine.change_state("IDLE")
			return
			
	if parent.check_horizontal_input() == 0:
		machine.change_state("CROUCH")
		return
		
	if parent.velocity.y > 0 && !parent.is_on_floor() && !parent.platform_detector.is_colliding() && !parent.platform_detector_2.is_colliding():
		machine.change_state("FALL")
		return

func exit():
	machine.previous_state = str(state_name)
	if !parent.invincible:
		parent.hurtbox_collision_shape.disabled = false
		parent.crouch_hurtbox_collision_shape.disabled = true
	if !parent.can_fall_through:
		parent.crouch_collision_shape.disabled = true
		parent.collision_shape.disabled = false 
