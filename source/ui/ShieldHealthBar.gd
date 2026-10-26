extends Control

@onready var shield_health_bar = $ShieldHealthBar

var can_regen = false
var wait_time = 5
var s_timer = 0
var can_start_timer = true

func _ready():
	SignalBus.connect("set_shield_health", on_set_shield_health.bind())
	SignalBus.connect("send_shield_damage", on_send_shield_damage.bind())
	
func on_set_shield_health(max_shield_health):
	shield_health_bar.max_value = max_shield_health
	shield_health_bar.value = max_shield_health
	
func _process(delta):
	if !can_regen:
		if shield_health_bar.value != shield_health_bar.max_value || shield_health_bar.value != 0:
			can_start_timer = true
			if can_start_timer:
				s_timer += delta
				if s_timer > wait_time: #once s_timer reaches wait_timer you can regen and s_timer can be reset
					can_regen = true
					can_start_timer = false
					s_timer = 0
					
	if shield_health_bar.value == shield_health_bar.max_value:
		can_regen = false
	
	if can_regen:
		shield_health_bar.value = move_toward(shield_health_bar.value, shield_health_bar.max_value, 50 * delta )
		var hud_shield_health = shield_health_bar.value
		SignalBus.emit_signal("send_shield_health", hud_shield_health)
		
func on_send_shield_damage(damage_received):
	s_timer = 0
	can_regen = false
	shield_health_bar.value -= damage_received
