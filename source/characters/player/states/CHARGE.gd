extends State

var parent : Player

func enter():
	print("Entered CHARGE State")
	parent.charge_attack_timer.start()
	parent.charge_particles.emitting = true
	parent.animated_sprite.play("CHARGE")

func process_state(delta):
	parent.apply_friction(delta)
	if Input.is_action_just_released("attack"):
		if parent.charged_attack:
			SignalBus.emit_signal("send_stamina_cost", parent.g_atck4_cost)
			if parent.g_atck4_cost <= parent.stamina:
				machine.change_state("G_ATK4")
			else:
				machine.change_state("NO_ATK")
				return
		if !parent.charged_attack:
			machine.change_state("NO_ATK")
			return
	if parent.health <= 0:
		machine.change_state("NO_ATK")
		return
		
func exit():
	parent.charge_attack_timer.stop()
