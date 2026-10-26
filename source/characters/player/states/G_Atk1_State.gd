extends State

var parent : Player

func enter():
	parent.parry()
	print("Entered G_ATK1 State")
	parent.animation_player.play("G_ATCK1")
	
func process_state(delta):
	parent.apply_friction(delta)
	if Input.is_action_just_pressed("jump"):
		parent.buffer_jump = true
		parent.buffer_jump_timer.start()
	if parent.can_input_attack:
		if Input.is_action_just_pressed("attack"):
			parent.chain_attack = true
	if Input.is_action_just_pressed("roll"):
		parent.buffer_roll = true
		parent.buffer_roll_timer.start()
	if Input.is_action_just_pressed("shield"):
		machine.change_state("SHIELD")
		return
	if parent.health <= 0:
		machine.change_state("NO_ATK")
		return
		
