extends Sprite2D

func _ready():
	brightEffect()

func brightEffect():
	var tween := create_tween()
	tween.set_loops()

	var base_scale = scale
	var base_modulate = modulate

	# Efecto de brillo
	tween.parallel().tween_property(self, "modulate", Color(1.10, 1.1, 1.1), 0.75)

	tween.tween_property(self, "scale", base_scale, 0.22)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "modulate", base_modulate, 0.22)
