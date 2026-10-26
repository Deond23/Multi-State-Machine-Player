extends State

var parent : Player

func enter():
	print("Entered Jump State")
	if parent.mov_state_machine.previous_state == "ROLL":
		parent.animation_player.stop()
		
	if parent.ledge_jump:
		parent.animated_sprite.play("LEDGE_JUMP")
	else:
		parent.animated_sprite.scale = Vector2(0.75, 1.5)
		parent.animated_sprite.play("JUMP")
		parent.velocity.y = parent.jump_strength

func process_state(delta):
	parent.check_climables()
	if Input.is_action_just_released("jump") and parent.velocity.y < parent.jump_strength/2.0:
		parent.velocity.y = parent.jump_strength/2.0
		
	if !parent.ledge_jump:
		parent.apply_acceleration(parent.walk_spd, parent.air_accel, delta)
		parent.flip_sprite()
		parent.apply_gravity(delta)
	else:
		var timer = get_tree().create_timer(0.2) #delays the jump so animation can prompt the player is about to jump
		await timer.timeout
		parent.flip_sprite()
		parent.velocity.y = parent.ledge_jump_strength
		if !parent.scaled:
			parent.animated_sprite.scale = Vector2(0.75, 1.5)
			parent.scaled = true
		parent.ledge_jump = false
		
	if parent.velocity.y > 0:
		machine.change_state("FALL")
		return
