extends Node2D

var timer = 3.0

func display_damage(damage_value, position_):
	var label = Label.new()
	label.text = str(damage_value)
	label.position = position_
	label.z_index = 1
	label.label_settings = LabelSettings.new()
	label.label_settings.outline_color = Color.BLACK
	label.label_settings.font_size = 20
	call_deferred("add_child", label)
	
	await label.resized
	
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 0.5)
	
	await tween.finished
	label.queue_free()
