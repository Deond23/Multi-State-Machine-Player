extends Control

@onready var health_bar = $HealthBar

func _ready():
	SignalBus.connect("set_health", on_set_health.bind())
	SignalBus.connect("send_player_damage", reduce_health.bind())
	
func on_set_health(max_health):
	health_bar.max_value = max_health
	health_bar.value = max_health
	
func reduce_health(damage_received):
	health_bar.value -= damage_received
