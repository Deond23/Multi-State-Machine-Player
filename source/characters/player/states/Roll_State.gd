extends State

var parent : Player

func enter():
	print("ENTERED ROLL STATE")
	parent.stamina -= parent.roll_cost
	parent.collision_shape.disabled = true
	parent.rolling_collision_shape.disabled = false
	parent.hurtbox_collision_shape.disabled = true
	parent.animation_player.play("ROLL")
	if parent.check_horizontal_input() > 0 || parent.animated_sprite.flip_h == false:
		parent.velocity.x += parent.roll_speed
		roll_dust()
	if parent.check_horizontal_input() < 0 || parent.animated_sprite.flip_h:
		parent.velocity.x -= parent.roll_speed
		roll_dust()

func process_state(delta):
	parent.apply_gravity(delta)
	
	if Input.is_action_just_pressed("jump"):
		if !parent.crouch_ceiling_detector.is_colliding() && !parent.crouch_ceiling_detector_2.is_colliding():
			machine.change_state("JUMP")
			return
			
	if Input.is_action_just_pressed("attack"):
		parent.buffer_attack = true
		parent.buffer_attack_timer.start()
		
func exit():
	parent.collision_shape.disabled = false
	parent.rolling_collision_shape.disabled = true
	parent.hurtbox_collision_shape.disabled = false
	
func roll_dust():
	var smoke_instance = parent.smoke.instantiate()
	smoke_instance.initial_animation = "DASH"
	smoke_instance.position = parent.position + Vector2(0, 8)
	smoke_instance.flip_h = true
	parent.get_parent().add_child(smoke_instance)
