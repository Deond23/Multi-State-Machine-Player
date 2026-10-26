extends State

var parent : Player

func enter():
	print("Entered SHIELD State")
	parent.velocity.x = 0
	parent.animation_player.play("SHIELD")
	parent.shield_collision_shape.disabled = false
	parent.hurtbox_collision_shape.disabled = true

func process_state(delta):
	parent.apply_friction(delta)
	
	if Input.is_action_just_released("shield"):
		machine.change_state("NO_ATK")
	if parent.shield_health <= 0:
		parent.can_shield = false
		machine.change_state("NO_ATK")
		
	if Input.is_action_just_pressed("attack"):
		if parent.stamina != 0 && parent.stamina - parent.shield_bash_cost >= 0:
			machine.change_state("SHIELD_BASH")
			return
	if parent.health <= 0:
		machine.change_state("NO_ATK")
		return
			
func exit():
	parent.hurtbox_collision_shape.disabled = false
	parent.shield_collision_shape.disabled = true

func _on_shield_hurtbox_area_entered(area):
	if area == null: 
		return

	# Check if the colliding area is a Hitbox
	var hitbox = area as Hitbox
	if hitbox == null:
		return
	
	var attack_direction = (hitbox.owner.global_position - parent.global_position).normalized()
	
	# Check if the attack is within the shield's blockable arc
	if is_in_front(attack_direction):
		parent.take_shield_damage(hitbox.damage_dealt)
	else:
		parent.take_damage(hitbox.damage_dealt)

# Helper function to determine if an attack is in front of the shield
func is_in_front(attack_direction: Vector2) -> bool:
	var shield_facing_direction = Vector2(parent.facing, 0)
	var angle_to_attack = shield_facing_direction.angle_to(attack_direction)
	return abs(angle_to_attack * 180 / PI) <= parent.shield_block_angle / 2
