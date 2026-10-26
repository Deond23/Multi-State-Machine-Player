extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var dazzed_timer = $DazzedTimer
@onready var parry_zone_collision = $ParryZone/CollisionShape2D
@onready var hitbox_collision = $Hitbox/CollisionShape2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var got_parried = false
var parry_time = 0.2
var parry_window_active = true

func _ready():
	animated_sprite.play("IDLE")
	parry_zone_collision.disabled = true
	
func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()

func _on_timer_timeout():
	parry_zone_collision.disabled = false  # Enable the parry zone after attack starts
	await flash_sprite(Vector3(1, 0, 0), 0.3)
	var parry_timer = get_tree().create_timer(parry_time)
	parry_timer.connect("timeout", _on_parry_grace_timer_timeout.bind())
	parry_window_active = true  # Enable the parry window
	animation_player.play("ATTACK")

func flash_sprite(rgb_values : Vector3, time : float):
	animated_sprite.material.set_shader_parameter("rgb", rgb_values)
	animated_sprite.material.set_shader_parameter("active", true)
	var timer = get_tree().create_timer(time)
	await timer.timeout
	animated_sprite.material.set_shader_parameter("active", false)

func _on_animation_player_animation_finished(anim_name):
	if !got_parried:
		if anim_name == "ATTACK":
			hitbox_collision.disabled = true
			animated_sprite.play("IDLE")

func _on_parry_zone_area_entered(area):
	if area is Hitbox:
		if area.owner is Player:
			if parry_window_active && area.owner.parry_timer.time_left > 0:
				hitbox_collision.set_deferred("disabled", true)
				got_parried = true
				area.owner.on_parry_success() 
				animated_sprite.play("DAZZED")
				print("PARRIED_BOT")
				velocity.x += area.owner.parry_impact
				dazzed_timer.start()
				attack_timer.stop()
				
func _on_timer_2_timeout():
	animation_player.stop()
	animated_sprite.play("IDLE")
	attack_timer.start()
	got_parried = false

func _on_parry_grace_timer_timeout():
	parry_window_active = false  # Disable the grace period after the timeout
	parry_zone_collision.disabled = true  # Disable the parry zone to reset
