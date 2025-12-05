# DopamineBar.gd
extends TextureRect

@onready var indicator: Sprite2D = $IndicatorSprite
@onready var target_zone: Control = $Target
@onready var sprite: Sprite2D = $BrainBarSprite

var bar_width: float = 0.0
var center_position: float = 0.0

var extra_tween: Tween
var pump_tween: Tween

func _ready():
	brightEffect()
	# Force initial update después de que el layout esté resuelto
	_update_bar_dimensions()
	_update_target_size()
	_update_indicator_position()

	DopamineManager.value_changed.connect(_on_dopamine_value_changed)
	DopamineManager.target_changed.connect(_on_targuet_value_changed)
	# escuchar cambios de tamaño del Control (re-layout). En Godot 4 el evento es "resized".
	connect("resized", Callable(self, "_on_size_changed"))

func _on_size_changed() -> void:
	_update_bar_dimensions()
	_update_target_size()
	_update_indicator_position()

func _update_bar_dimensions() -> void:
	# En Control, el tamaño real del área es rect_size
	bar_width = size.x
	center_position = bar_width * 0.5

func _on_dopamine_value_changed():
	_update_indicator_position()

func _on_targuet_value_changed():
	_update_target_size()
	_update_indicator_position()

func _update_target_size():

	var target_value = DopamineManager.get_target()
	var maximum = DopamineManager.get_maxim()
	if maximum == 0:
		return

	# ancho proporcional del target dentro del rango [-maximum, +maximum]
	# calculamos la proporción del intervalo [-maximum .. +maximum] que ocupa [-target .. +target]
	# pero queremos centrar la zona en el centro, y target referencia positiva:
	var target_ratio = target_value / (maximum * 2.0) * 2.0   # simplificado: target/maximum -> pero lo adaptamos abajo

	# Más directo y seguro: target ocupa (target / maximum) del semiancho
	var semiw = bar_width * 0.5
	var target_width = clamp((target_value / maximum) * bar_width, 0.0, bar_width)

	# En tu diseño target_zone se centra en el medio de la barra
	target_zone.size.x = target_width
	target_zone.position.x = center_position - (target_width * 0.5)

func _update_indicator_position():

	var current_level = DopamineManager.get_current()
	var maximum = DopamineManager.get_maxim()
	if maximum == 0:
		return

	# Normalizamos current a -1..1 usando máximo como semiram
	var normalized_value = current_level / maximum
	normalized_value = clamp(normalized_value, -1.0, 1.0)

	# Convertir a posición en píxeles desde el centro (offset)
	var pixel_offset = normalized_value * (bar_width * 0.5)

	# Indicador centrado con su ancho en cuenta
	var new_x = center_position + pixel_offset - (indicator.scale.x * 0.5)
	indicator.position.x = clamp(new_x, 0.0 - indicator.scale.x, bar_width - 0.0)
	
	#  NUEVAS ANIMACIONES SEGÚN LA POSICIÓN DEL INDICATOR

	var indicator_left = indicator.global_position.x
	var target_left = target_zone.global_position.x
	var target_right = target_left + target_zone.size.x

	var current_color := sprite.modulate

	# 1) INDICATOR POR DEBAJO (IZQUIERDA)
	if indicator_left < target_left:
		_apply_low_dopa_effect()
		return

	# 2) INDICATOR POR ENCIMA (DERECHA)
	if indicator_left > target_right:
		_apply_high_dopa_effect()
		return

	# 3) DENTRO DEL RANGO (reset)
	_reset_sprite_state()


func brightEffect():
	var tween := sprite.create_tween()
	tween.set_loops()

	var base_scale = scale
	var base_modulate = modulate

	# Efecto de brillo
	tween.parallel().tween_property(self, "modulate", Color(1.10, 1.1, 1.1), 0.75)

	tween.tween_property(self, "scale", base_scale, 0.22)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "modulate", base_modulate, 0.22)

func _apply_low_dopa_effect():
	# Cancelar animaciones previas
	if extra_tween:
		extra_tween.kill()
	if pump_tween:
		pump_tween.kill()

	extra_tween = create_tween()

	# Gris progresivo
	extra_tween.tween_property(
		sprite, "modulate", Color(0.4, 0.4, 0.4), 0.3
	)

	# Efecto “agrietado”: micro temblor visual
	extra_tween.parallel().tween_property(
		sprite, "scale", Vector2(0.95, 1.02), 0.15
	).set_trans(Tween.TRANS_SINE)


func _apply_high_dopa_effect():
	# cancelar animaciones previas
	if extra_tween:
		extra_tween.kill()

	extra_tween = create_tween()
	
	# Verde progresivo
	extra_tween.tween_property(
		sprite, "modulate", Color(0.5, 1.0, 0.5), 0.3
	)

	# Bombeo continuo
	if pump_tween == null or !pump_tween.is_running():
		pump_tween = sprite.create_tween()
		pump_tween.set_loops()
		pump_tween.tween_property(sprite, "scale", Vector2(1.08, 1.08), 0.25)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pump_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _reset_sprite_state():
	if extra_tween:
		extra_tween.kill()
	if pump_tween:
		pump_tween.kill()

	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1), 0.25)
	t.parallel().tween_property(sprite, "scale", Vector2(1, 1), 0.25)
