extends State

var parent : Player

func enter():
	parent.parry()
	parent.hitbox.damage_dealt = parent.shield_bash_dmg
	parent.hitbox.knockback = parent.shield_bash_knockback
	parent.stamina -= parent.shield_bash_cost
	SignalBus.emit_signal("send_stamina_cost", parent.shield_bash_cost)
	parent.animation_player.play("SHIELD_BASH")
	if parent.health <= 0:
		machine.change_state("NO_ATK")
		return
	
func exit():
	parent.hitbox.damage_dealt = parent.sword_atk_dmg
	parent.hitbox.knockback = parent.sword_atck_knockback
