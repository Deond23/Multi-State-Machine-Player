extends Control

@onready var stamina_bar = $StaminaBar
@onready var animation_player = $AnimationPlayer

var can_regen = false
var wait_time = 2
var s_timer = 0
var can_start_timer = true

func _ready():
	SignalBus.connect("set_stamina", on_set_stamina.bind())
	SignalBus.connect("send_stamina_cost", reduce_stamina.bind())
	
func on_set_stamina(max_stamina):
	stamina_bar.max_value = max_stamina
	stamina_bar.value = max_stamina
	
func _process(delta):
	if !can_regen:
		if stamina_bar.value != stamina_bar.max_value || stamina_bar.value != 0:
			can_start_timer = true
			if can_start_timer:
				s_timer += delta
				if s_timer > wait_time: #once s_timer reaches wait_timer you can regen and s_timer can be reset
					can_regen = true
					can_start_timer = false
					s_timer = 0
					
	if stamina_bar.value == stamina_bar.max_value:
		can_regen = false
	
	if can_regen:
		stamina_bar.value = move_toward(stamina_bar.value, stamina_bar.max_value, 50 * delta )
		var hud_stamina = stamina_bar.value
		SignalBus.emit_signal("send_stamina", hud_stamina)
		
func reduce_stamina(cost):
	if cost <= stamina_bar.value:
			s_timer = 0
			can_regen = false
			stamina_bar.value -= cost
	else:
		animation_player.play("StaminaBar_Shake")

func _on_animation_player_animation_finished(_anim_name):
	stamina_bar.modulate = Color.WHITE
