extends State

var parent : Player

func enter():
	print("Entered NO_ATK_State")
	parent.animation_player.stop()
	if parent.is_on_floor():
		if parent.check_horizontal_input() == 0:
			parent.animated_sprite.play("IDLE")
		else:
			parent.animated_sprite.play("WALK")
	else:
		parent.animated_sprite.play("FALL")
	parent.hitbox.damage_dealt = parent.sword_atk_dmg
	parent.hitbox.knockback = parent.sword_atck_knockback
	parent.shield_collision_shape.disabled = true
	parent.hitbox_collision_shape.disabled = true
	parent.hitbox2_collision_shape.disabled = true
	parent.charge_particles.emitting = false
			
func process_state(delta):
	if parent.health > 0:
		if parent.mov_state_machine.get_current_state() not in ["ROLL", "CROUCH", "CROUCH_WALK", "CLIMB", "LEDGE"]:
			if Input.is_action_just_pressed("attack") || parent.buffer_attack:
				if parent.is_on_floor():
					machine.change_state("G_ATK1")
				else:
					if parent.air_atcks == 0:
						parent.air_atcks += 1
						machine.change_state("G_ATK3")
			
		if parent.is_on_floor():
			if Input.is_action_pressed("attack") && parent.is_on_floor() && !parent.mov_state_machine.previous_state == "ROLL":
				if parent.mov_state_machine.get_current_state() not in ["ROLL", "CROUCH", "CROUCH_WALK", "CLIMB", "LEDGE"]:
					if !parent.animation_player.is_playing():
						machine.change_state("CHARGE")
			
			if Input.is_action_pressed("shield"):
				if !parent.animation_player.is_playing():
					if parent.can_shield:
						machine.change_state("SHIELD")
