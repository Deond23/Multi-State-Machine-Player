extends State

var parent : Player

func enter():
	print("Entered ATK 4 State")
	parent.hitbox.damage_dealt = parent.charged_atk_dmg
	parent.hitbox.knockback = parent.charged_atk_knockback
	parent.hurtbox_collision_shape.disabled = true
	parent.charge_particles.emitting = false
	parent.animation_player.play("G_ATCK4")
	parent.stamina -= parent.g_atck4_cost
	if parent.animated_sprite.flip_h == false:
		parent.velocity.x += parent.charge_atk_dash_spd
	else:
		parent.velocity.x -= parent.charge_atk_dash_spd

func process_state(delta):
	if Input.is_action_just_pressed("jump"):
		parent.buffer_jump = true
		parent.buffer_jump_timer.start()
	if Input.is_action_just_pressed("roll"):
		parent.buffer_roll = true
		parent.buffer_roll_timer.start()
	if parent.health <= 0:
		machine.change_state("NO_ATK")
		return
		
func exit():
	parent.hurtbox_collision_shape.disabled = false
	parent.charged_attack = false
