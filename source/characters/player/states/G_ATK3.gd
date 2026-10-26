extends State

var parent : Player

func enter():
	print("Entered G_ATK3 State")
	parent.animation_player.play("G_ATCK3")

func process_state(delta):
	if Input.is_action_just_pressed("jump"):
		parent.buffer_jump = true
		parent.buffer_jump_timer.start()
	if Input.is_action_just_pressed("roll"):
		parent.buffer_roll = true
		parent.buffer_roll_timer.start()
	if Input.is_action_just_pressed("shield"):
		machine.change_state("SHIELD")
		return
	if parent.health <= 0:
		machine.change_state("NO_ATK")
		return
		

func exit():
	if parent.hitbox.knockback != parent.sword_atck_knockback:
		parent.hitbox.knockback = parent.sword_atck_knockback
