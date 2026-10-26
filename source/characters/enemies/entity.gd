extends CharacterBody2D
class_name Entity

@export var health : int = 100
@export var mass : float = 1.0

var facing : float = 1

var air_density : float = 1
var drag_coefficient : float = 0.06
var friction_coefficient: float 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func apply_gravity(delta):
	velocity.y += gravity * delta
	
func apply_friction(delta):
	var friction = friction_coefficient * mass
	velocity.x = lerp(velocity.x, 0.0, friction * delta)
		
func apply_air_drag():
	var air_drag = -0.5 * drag_coefficient * air_density * velocity.length() * velocity.normalized()
	velocity += air_drag
	
func apply_knockback(knockback : Vector2, knockback_dir : float):
	var knockback_force = knockback * knockback_dir
	velocity.x += knockback_force.x
	if knockback_dir > 0:
		velocity.y += knockback_force.y
	else:
		velocity.y += -knockback_force.y

func flip_sprite():
	pass
		
func flash_sprite(rgb_values : Vector3, time : float):
	pass

func take_damage(damage_received : int): # Polymorphism
	pass

