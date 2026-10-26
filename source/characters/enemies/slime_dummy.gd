extends Entity

enum Movement_States{IDLE, WALK, DEATH}

enum Attack_States{NO_ATCK, BITE}

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hurtbox_collision_shape = $Hurtbox/CollisionShape2D
@onready var hit_sound = $Hurt

var deccel = 2.5

func _physics_process(delta):
	apply_gravity(delta)
	apply_friction(delta)
	move_and_slide()
	
func apply_friction(delta):
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, delta * deccel)
				
func take_damage(damage_received : int):
	DamagePopup.display_damage(damage_received, position + Vector2(0, -25))
	SignalBus.emit_signal("trigger_slash")
	animated_sprite.play("HURT")
	hit_sound.play()
	flash_sprite(Vector3(1, 1, 1), 0.075)
	
func flash_sprite(rgb_values : Vector3, time : float):
	animated_sprite.material.set_shader_parameter("rgb", rgb_values)
	animated_sprite.material.set_shader_parameter("active", true)
	var timer = get_tree().create_timer(time)
	await timer.timeout
	animated_sprite.material.set_shader_parameter("active", false)
