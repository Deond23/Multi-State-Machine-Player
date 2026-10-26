extends State

var parent : Player

func enter():
	print("Entered Crouch State")	
	parent.velocity.x = 0
	parent.collision_shape.disabled = true
	parent.crouch_collision_shape.disabled = false
	parent.hurtbox_collision_shape.disabled = true
	if !parent.invincible:
		parent.crouch_hurtbox_collision_shape.disabled = false
	if machine.previous_state == "IDLE":
		parent.animated_sprite.play("CROUCH")
	if machine.previous_state == "CROUCH_WALK" || machine.previous_state == "ROLL":
			parent.animated_sprite.play("CROUCH_IDLE")
			
func process_state(delta):
	parent.apply_gravity(delta)
	parent.apply_friction(delta)
	parent.apply_gravity(delta)
	if parent.animated_sprite.animation_finished && parent.animated_sprite.animation == "CROUCH":
		parent.animated_sprite.play("CROUCH_IDLE")
		
	if !Input.is_action_pressed("crouch") && !parent.crouch_ceiling_detector.is_colliding() && !parent.crouch_ceiling_detector_2.is_colliding():
		machine.change_state("IDLE")
		return
			
	if parent.check_horizontal_input() != 0:
		machine.change_state("CROUCH_WALK")
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
		
