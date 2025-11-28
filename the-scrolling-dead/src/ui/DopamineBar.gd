# DopamineBar.gd
extends TextureRect

@onready var indicator: Control = $Indicator
@onready var target_zone: Control = $Target

var bar_width: float = 0.0
var center_position: float = 0.0

func _ready():
	# Force initial update después de que el layout esté resuelto
	_update_bar_dimensions()
	_update_target_size()
	_update_indicator_position()

	DopamineManager.value_changed.connect(_on_dopamine_value_changed)
	DopamineManager.target_changed.connect(_on_targuet_value_changed)
	# escuchar cambios de tamaño del Control (re-layout)
	connect("size_changed", Callable(self, "_on_size_changed"))

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
	var new_x = center_position + pixel_offset - (indicator.size.x * 0.5)
	indicator.position.x = clamp(new_x, 0.0 - indicator.size.x, bar_width - 0.0)
