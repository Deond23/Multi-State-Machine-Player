extends State

var parent : Player

func enter():
	print("Entered DEATH State")
	SignalBus.emit_signal("send_player_damage", parent.health)
	parent.animation_player.stop()
	parent.animated_sprite.play("DEATH")
	parent.has_died = true
	parent.velocity = Vector2.ZERO
	parent.hurtbox_collision_shape.disabled = true

func process_state(delta):
	parent.apply_gravity(delta)
