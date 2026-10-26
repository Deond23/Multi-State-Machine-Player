extends AnimatedSprite2D

var initial_animation : String

func _ready():
	play(initial_animation)

func _on_animation_finished():
	queue_free()
