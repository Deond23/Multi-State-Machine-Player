extends State

var parent : Player

func enter():
	print("Entered FALL State")
	if !parent.animation_player.is_playing():
		parent.animated_sprite.play("FALL")

func process_state(delta):
	parent.	check_climables()
	parent.flip_sprite()
	parent.apply_gravity(delta)
	parent.apply_acceleration(parent.walk_spd, parent.air_accel, delta)
	if parent.coyote_jump && !parent.can_fall_through:
		if Input.is_action_just_pressed("jump"):
			machine.change_state("JUMP")
			return
	
	if Input.is_action_just_pressed("jump"):
		parent.buffer_jump = true
		parent.buffer_jump_timer.start()
		
	if Input.is_action_just_pressed("attack") && parent.air_atcks != 0:
		parent.buffer_attack = true
		parent.buffer_attack_timer.start()
		
	if Input.is_action_just_pressed("roll"):
		parent.buffer_roll = true
		parent.buffer_roll_timer.start()
		
	if parent.is_on_floor() || parent.platform_detector.is_colliding() || parent.platform_detector_2.is_colliding():
		parent.can_fall_through = false
		if !parent.can_fall_through:
			machine.change_state("IDLE")
			return
			
func exit():
	if parent.is_on_floor():
		machine.previous_state = str(state_name)
		if !machine.previous_state == "ROLL":
			parent.animated_sprite.scale = Vector2(1.25, 0.75)
			var smoke_instance = parent.smoke.instantiate()
			smoke_instance.initial_animation = "JUMP&LAND"
			smoke_instance.position = parent.position + Vector2(0, 20)
			get_parent().add_child(smoke_instance)
