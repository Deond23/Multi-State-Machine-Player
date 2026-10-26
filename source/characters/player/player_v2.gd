class_name Player
extends Entity

@onready var coyote_jump_timer = $Timers/CoyoteJumpTimer
@onready var buffer_jump_timer = $Timers/BufferJumpTimer
@onready var charge_attack_timer = $Timers/ChargeAttackTimer
@onready var buffer_attack_timer = $Timers/BufferAttackTimer
@onready var invincible_frame_timer = $Timers/InvincibleFrameTimer
@onready var buffer_roll_timer = $Timers/BufferRollTimer
@onready var parry_timer = $Timers/ParryTimer

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var invincibility_frame_animation = $InvinciblityFrameAnimation

@onready var collision_shape = $CollisionShape2D
@onready var shield_hurtbox = $Area2Ds/Shield_Hurtbox
@onready var shield_collision_shape = $Area2Ds/Shield_Hurtbox/CollisionShape2D
@onready var hitbox = $Area2Ds/Hitbox
@onready var hitbox_2 = $Area2Ds/Hitbox2
@onready var hitbox_collision_shape = $Area2Ds/Hitbox/CollisionShape2D
@onready var hitbox2_collision_shape = $Area2Ds/Hitbox2/CollisionShape2D
@onready var hurtbox = $Area2Ds/Hurtbox
@onready var crouch_hurtbox = $Area2Ds/Crouch_Hurtbox
@onready var hurtbox_collision_shape = $Area2Ds/Hurtbox/CollisionShape2D
@onready var crouch_collision_shape = $Crouch_CollisionShape2D
@onready var crouch_hurtbox_collision_shape = $Area2Ds/Crouch_Hurtbox/CollisionShape2D
@onready var ledge_hurtbox_collision_shape = $Area2Ds/Ledge_Hurtbox/CollisionShape2D
@onready var rolling_collision_shape = $Rolling_CollisionShape2D

@onready var ledge_checker = $Raycasts/Ledge_Checker
@onready var crouch_ceiling_detector = $Raycasts/Crouch_Ceiling_Detector
@onready var crouch_ceiling_detector_2 = $Raycasts/Crouch_Ceiling_Detector2
@onready var platform_detector = $Raycasts/Platform_Detector
@onready var platform_detector_2 = $Raycasts/Platform_Detector2
@onready var climbable_detector = $Raycasts/Climbable_Checker

@onready var charge_particles = $CPUParticles2D
@onready var shield_impact_sound = $Sounds/Shield_Hit
@onready var slash_1 = $Sounds/Slash_1
@onready var slash_2 = $Sounds/Slash_2
@onready var slash_3 = $Sounds/Slash_3

@onready var mov_state_machine = $Mov_StateMachine
@onready var atk_state_machine = $Atk_StateMachine

@export var max_stamina : int = 100
@export var max_shield_health : int = 150
@export var roll_cost : int = 25
@export var g_atck4_cost : int = 50
@export var shield_bash_cost = 10

@export var sword_atk_dmg : int = 25
@export var shield_bash_dmg : int = 15 
@export var charged_atk_dmg : int = 100
@export var sword_atck_knockback = Vector2(150, 0)
@export var shield_bash_knockback = Vector2(500, 0)
@export var charged_atk_knockback = Vector2(1500, 0)

@export var walk_accel : float = 4
@export var crouch_accel : float = 3
@export var air_accel : float = 2.25
@export var climb_accel : float = 6
@export var walk_spd : int = 350
@export var crouch_walk_spd : int = 175
@export var charge_atk_dash_spd : int = 875
@export var climb_speed : int = 200
@export var roll_speed : int = 525
@export var parry_impact : int = 500

@export var jump_strength : int = -475
@export var ledge_jump_strength = -300
@export var climb_jump_strength = 200
@export var gravity_multipler : float = 1.75

var stamina : int
var shield_health : int

var shield_block_angle = 90 # Default to a 90-degree arc (±45 degrees from the shield's direction)

var smoke = preload("res://source/misc/smoke.tscn")

var coyote_jump = false
var buffer_jump = false
var chain_attack = false
var can_input_attack = false
var can_fall_through = false
var buffer_attack = false
var buffer_roll = false
var charged_attack = false
var can_shield = true
var ledge_jump = false
var has_died = false
var grab_ledge = false
var invincible = false
var scaled = false
var can_parry = true
var just_parried = false

var air_atcks = 0

func _ready():
	mov_state_machine.init(self, mov_state_machine)
	atk_state_machine.init(self, atk_state_machine)
	SignalBus.emit_signal("set_health", health)
	SignalBus.emit_signal("set_shield_health", max_shield_health)
	SignalBus.emit_signal("set_stamina", max_stamina)
	SignalBus.connect("send_stamina", on_send_stamina.bind())
	SignalBus.connect("send_shield_health", on_send_shield_health.bind())
	hitbox.damage_dealt = sword_atk_dmg
	hitbox_2.damage_dealt = sword_atk_dmg
	hitbox.knockback = sword_atck_knockback
	hitbox_2.knockback = sword_atck_knockback
	shield_health = max_shield_health
	stamina = max_stamina
	hitbox_collision_shape.disabled = true
	hitbox2_collision_shape.disabled = true
	mov_state_machine.change_state("IDLE")
	atk_state_machine.change_state("NO_ATK")
	
func _physics_process(delta):
	apply_air_drag()
	reset_sprite_scale(delta)
	
	if health <= 0 && !has_died:
		animated_sprite.stop()
		atk_state_machine.change_state("NO_ATK")
		mov_state_machine.change_state("DEATH")

	find_friction_coefficient()
	check_ledges()
	check_hazards()
	check_one_way_platforms()
		
	if invincible:
		invincibility_frame_animation.play("Flash")
		
	mov_state_machine.process_state(delta)
	atk_state_machine.process_state(delta)
		
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_left_ground = not is_on_floor() and was_on_floor and velocity.y >= 0
	if just_left_ground:
		if !can_fall_through:
			coyote_jump = true
			coyote_jump_timer.start()

func check_horizontal_input():
	var horizontal_direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return horizontal_direction
	
func check_vertical_input():
	var vertical_direction = Input.get_action_strength("crouch") - Input.get_action_strength("move_up")
	return vertical_direction
	
func parry():
	if can_parry:
		can_parry = false
		print("parry_started")
		parry_timer.start()

func take_damage(damage_received : int):
	print("OUCH")
	DamagePopup.display_damage(damage_received, position)
	health -= damage_received
	SignalBus.emit_signal("send_damage_value", damage_received)
	SignalBus.emit_signal("send_player_damage", damage_received)
	
	invincible = true
	hurtbox_collision_shape.set_deferred("disabled", true)
	crouch_hurtbox_collision_shape.set_deferred("disabled", true)
	invincible_frame_timer.start()
	animated_sprite.play("HURT")
	
func take_shield_damage(damage_received):
	if !just_parried:
		shield_health -= damage_received
		velocity.x += -facing * 250
		SignalBus.emit_signal("send_shield_damage", damage_received)

func apply_gravity(delta):
	if velocity.y > 0:
		velocity.y += gravity * gravity_multipler * delta 
	else:
		velocity.y += gravity * delta
		
func apply_acceleration(speed: int, accel : float, delta): # Cannot share apply_acceleration with other entities (GDscript does not support method overloading)
	if mov_state_machine.get_current_state() == "CLIMB":
		velocity.y = lerp(velocity.y, speed * check_vertical_input(), delta * accel)
	else:
		velocity.x = lerp(velocity.x, speed * check_horizontal_input(), delta * accel)
	
func find_friction_coefficient(): # Cannot share with out entities (Not every entity will have a raycast named platform_detector or any raycast)
	if platform_detector.is_colliding():
		var collider = platform_detector.get_collider()
		if collider is TileMap && collider.is_in_group("tiles"):
			var cell = collider.local_to_map(platform_detector.get_collision_point())
			var tile_data = collider.get_cell_tile_data(0, cell)
			if tile_data != null:
				var friction_data = tile_data.get_custom_data("Friction_Coefficient")
				friction_coefficient = friction_data

func flip_sprite():
	if check_horizontal_input() > 0:
		facing = 1
		animated_sprite.flip_h = false
		crouch_collision_shape.position.x = 6
		crouch_hurtbox.position.x = 7
		hitbox.position.x = 35
		hitbox_2.position.x = -35
		ledge_checker.target_position.x = 21
		shield_hurtbox.position.x = 12
	elif check_horizontal_input() < 0:
		facing = -1
		animated_sprite.flip_h = true
		crouch_collision_shape.position.x = -6
		crouch_hurtbox.position.x = -10
		hitbox.position.x = -35
		hitbox_2.position.x = 35
		ledge_checker.target_position.x = -21
		shield_hurtbox.position.x = -12
		
func reset_sprite_scale(delta):
	animated_sprite.scale.x = move_toward(animated_sprite.scale.x, 1, 2 * delta)
	animated_sprite.scale.y = move_toward(animated_sprite.scale.y, 1, 2 * delta)
	
func check_ledges():
	if ledge_checker.is_colliding():
		var collider = ledge_checker.get_collider()
		if collider != null:
			if collider is TileMap && collider.is_in_group("tiles"):
				var cell : Vector2i
				if animated_sprite.flip_h == false:
					cell = collider.local_to_map(ledge_checker.get_collision_point())
				else: 
					cell = collider.local_to_map(ledge_checker.get_collision_point()) - Vector2i(1, 0)
				var tile_data = collider.get_cell_tile_data(0, cell)
				if tile_data != null:
					var ledge_data = tile_data.get_custom_data("Ledge")
					if ledge_data:
						if Input.is_action_pressed("jump") && !grab_ledge && velocity.y > velocity.y/2.0:
							grab_ledge = true
							mov_state_machine.change_state("LEDGE")

func check_one_way_platforms():
	if platform_detector.is_colliding() and platform_detector_2.is_colliding():
		var collider = platform_detector.get_collider()
		var collider2 = platform_detector_2.get_collider()
		if collider != null:
			if collider is TileMap && collider.is_in_group("tiles"):
				var cell = collider.local_to_map(platform_detector.get_collision_point())
				var cell2 = collider2.local_to_map(platform_detector_2.get_collision_point())
				var tile_data = collider.get_cell_tile_data(0, cell)
				var platform_data = tile_data.get_custom_data("Platform")
				var tile_data_2 = collider.get_cell_tile_data(0, cell2)
				var platform_data_2 = tile_data_2.get_custom_data("Platform")
				if platform_data && platform_data_2:
					if Input.is_action_pressed("crouch"):
						if Input.is_action_just_pressed("jump"):
							can_fall_through = true
							crouch_collision_shape.disabled = true
							platform_detector.enabled = false
							platform_detector_2.enabled = false
							collision_shape.disabled = true
							var timer = get_tree().create_timer(0.05)
							await timer.timeout
							crouch_collision_shape.disabled = false
							platform_detector.enabled = true
							platform_detector_2.enabled = true
							collision_shape.disabled = false
						
func check_hazards():
	if platform_detector.is_colliding():
		var collider = platform_detector.get_collider()
		if collider != null:
			if collider is TileMap && collider.is_in_group("tiles"):
				var cell = collider.local_to_map(platform_detector.get_collision_point())
				var tile_data = collider.get_cell_tile_data(0, cell)
				var hazard_data = tile_data.get_custom_data("Hazard")
				if hazard_data && !has_died:
					mov_state_machine.change_state("DEATH")
					
	if platform_detector_2.is_colliding():
		var collider = platform_detector_2.get_collider()
		if collider != null:
			if collider is TileMap && collider.is_in_group("tiles"):
				var cell = collider.local_to_map(platform_detector_2.get_collision_point())
				var tile_data = collider.get_cell_tile_data(0, cell)
				var hazard_data = tile_data.get_custom_data("Hazard")
				if hazard_data && !has_died:
					mov_state_machine.change_state("DEATH")
					
func check_climables():
	if climbable_detector.is_colliding():
		var collider = climbable_detector.get_collider()
		if collider is TileMap && collider.is_in_group("terrain"):
			var cell = collider.local_to_map(climbable_detector.get_collision_point())
			var tile_data = collider.get_cell_tile_data(0, cell)
			if tile_data != null:
				var climb_data = tile_data.get_custom_data("Climbable")
				if climb_data:
					if Input.is_action_pressed("move_up"):
						mov_state_machine.change_state("CLIMB")

func _on_coyote_jump_timer_timeout():
	coyote_jump = false
	print("times_up_for_coyotejump")
	
func _on_buffer_jump_timer_timeout():
	buffer_jump = false
	print("times_up_for_bufferjump")
	
func _on_buffer_attack_timer_timeout():
	buffer_attack = false
	print("times_up_for_bufferattack")
	
func _on_buffer_roll_timer_timeout():
	buffer_roll = false
	
func _on_charge_attack_timer_timeout():
	flash_sprite(Vector3(1, 1, 0), 0.075)
	charged_attack = true
	
func _on_invinci_frame_timer_timeout():
	invincible = false
	invincibility_frame_animation.stop()
	animated_sprite.visible = true
	if !has_died:
		if mov_state_machine.get_current_state() == "CROUCH":
			crouch_hurtbox_collision_shape.disabled = false
		else:
			hurtbox_collision_shape.disabled = false
	
func on_send_stamina(hud_stamina):
	stamina = hud_stamina
	
func on_send_shield_health(hud_shield_health):
	can_shield = true
	shield_health = hud_shield_health

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "HURT":
		if !has_died:
			if grab_ledge:
				animated_sprite.play("LEDGE_GRAB")
			match mov_state_machine.get_current_state():
				"CROUCH":
					animated_sprite.play("CROUCH_IDLE")
				"CROUCH_WALK":
					animated_sprite.play("CROUCH_WALK")
				"IDLE":
					animated_sprite.play("IDLE")
				"WALK":
					animated_sprite.play("WALK")

func _on_animation_player_animation_finished(anim_name):
			
	if anim_name == "SHIELD" && atk_state_machine.get_current_state() != "SHIELD":
		shield_collision_shape.disabled = true
		
	if anim_name == "ROLL":
		if crouch_ceiling_detector.is_colliding() || crouch_ceiling_detector_2.is_colliding() || Input.is_action_pressed("crouch"):
			mov_state_machine.change_state("CROUCH")
		if !crouch_ceiling_detector.is_colliding() && !crouch_ceiling_detector_2.is_colliding() && !Input.is_action_pressed("crouch"):
			mov_state_machine.change_state("IDLE")
			
	if anim_name == "G_ATCK1":
		if !chain_attack:
			can_input_attack = false
			atk_state_machine.change_state("NO_ATK")
		if chain_attack:
			can_input_attack = false
			chain_attack = false
			atk_state_machine.change_state("G_ATK2")
			
	if anim_name == "G_ATCK2":
		if !chain_attack:
			can_input_attack = false
			atk_state_machine.change_state("NO_ATK")
			
		if chain_attack:
			can_input_attack = false
			chain_attack = false
			atk_state_machine.change_state("G_ATK3")
			
	if anim_name == "G_ATCK3":
		atk_state_machine.change_state("NO_ATK")
		
	if anim_name == "G_ATCK4":
		atk_state_machine.change_state("NO_ATK")
		
	if anim_name == "SHIELD_BASH":
		if Input.is_action_pressed("shield"):
			atk_state_machine.change_state("SHIELD")
		else:
			atk_state_machine.change_state("NO_ATK")
			
func ready_chain_attack():
	can_input_attack = true
	
func flash_sprite(rgb_values : Vector3, time : float): 
	animated_sprite.material.set_shader_parameter("rgb", rgb_values)
	animated_sprite.material.set_shader_parameter("active", true)
	var timer = get_tree().create_timer(time)
	await timer.timeout
	animated_sprite.material.set_shader_parameter("active", false)

func _on_parry_timer_timeout():
	can_parry = true
	just_parried = false
	
func on_parry_success():
	print("PARRIED")
	just_parried = true
	hurtbox_collision_shape.set_deferred("disabled", true)
	velocity.x += -facing * parry_impact
	animated_sprite.play("SHIELD_BASH")
	flash_sprite(Vector3(0, 1, 0), 0.075)
	
