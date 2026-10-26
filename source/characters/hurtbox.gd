extends Area2D
class_name Hurtbox

@export var except: String
func _on_area_entered(area: Area2D):
	if area == null: 
		return

	var hitbox = area as Hitbox
	if hitbox == null:
		return

	if !hitbox.is_in_group(except):
		if owner.has_method("take_damage"):
			if owner is Player:
				if owner.just_parried != null:
					if !owner.just_parried:
						owner.take_damage(hitbox.damage_dealt)
			else:
				owner.take_damage(hitbox.damage_dealt)
			
		if owner.has_method("apply_knockback"):
			if "facing" in hitbox.owner:
				owner.apply_knockback(hitbox.knockback, hitbox.owner.facing)

		if owner.has_method("flash_sprite"):
			owner.flash_sprite(Vector3(1, 1, 1), 0.075)
