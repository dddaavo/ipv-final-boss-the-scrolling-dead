extends TextureRect

@onready var color_rect = $ColorRect

func _ready():
	# Conectar a las señales del DopamineManager
	DopamineManager.value_changed.connect(_on_dopamine_value_changed)
	DopamineManager.game_over.connect(_on_game_over)
	
	# Actualizar transparencia inicial
	_update_transparency()

func _on_dopamine_value_changed():
	_update_transparency()

func _on_game_over():
	# En game over, solo mostramos el warning si es por valores negativos
	var current = DopamineManager.get_current()
	if current < 0:
		_set_alpha(1.0)
	else:
		_set_alpha(0.0)

func _update_transparency():
	var current = DopamineManager.get_current()
	var target = DopamineManager.get_target()
	var maximum = DopamineManager.get_maxim()
	
	var alpha = 0.0
	
	# Solo se activa cuando los valores son negativos
	if current >= 0:
		# Valores positivos o cero: completamente transparente
		alpha = 0.0
	elif current >= -target:
		# Valores negativos pero dentro del target: completamente transparente
		alpha = 0.0
	elif current <= -maximum:
		# En el máximo negativo (game over): completamente opaco
		alpha = 1.0
	else:
		# Fuera del target negativo pero antes del máximo: interpolación
		# Calculamos qué tan lejos estamos del target hacia el máximo (en valores negativos)
		var distance_from_target = abs(current) - target
		var distance_range = maximum - target
		alpha = distance_from_target / distance_range
		# Aseguramos que esté entre 0 y 1
		alpha = clamp(alpha, 0.0, 1.0)
	
	_set_alpha(alpha)

func _set_alpha(alpha: float):
	if color_rect:
		var current_color = color_rect.color
		current_color.a = alpha
		color_rect.color = current_color
