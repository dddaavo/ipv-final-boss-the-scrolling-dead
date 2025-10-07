extends TextureRect

@onready var color_rect = $ColorRect

func _ready():
	# Conectar a las señales del DopamineManager
	DopamineManager.connect("value_changed", Callable(self, "_on_dopamine_value_changed"))
	DopamineManager.connect("game_over", Callable(self, "_on_game_over"))
	
	# Actualizar transparencia inicial
	_update_transparency()

func _on_dopamine_value_changed():
	_update_transparency()

func _on_game_over():
	# En game over, el warning es completamente opaco (0% transparencia)
	_set_alpha(1.0)

func _update_transparency():
	var current = abs(DopamineManager.get_current())
	var target = DopamineManager.get_target()
	var maximum = DopamineManager.get_maxim()
	
	var alpha = 0.0
	
	if current <= target:
		# Dentro del target: completamente transparente
		alpha = 0.0
	elif current >= maximum:
		# En el máximo (game over): completamente opaco
		alpha = 1.0
	else:
		# Fuera del target pero antes del máximo: interpolación
		# Calculamos qué tan lejos estamos del target hacia el máximo
		var distance_from_target = current - target
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
