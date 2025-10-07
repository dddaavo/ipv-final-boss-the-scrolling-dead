extends TextureRect

@onready var sprite_neg = $SpriteNegativo
@onready var sprite_pos = $SpritePositivo

func _ready():
	# Conectar a las señales del DopamineManager
	DopamineManager.value_changed.connect(_on_dopamine_value_changed)
	DopamineManager.game_over.connect(_on_game_over)
	
	# Actualizar transparencia inicial
	_update_transparency()

func _on_dopamine_value_changed():
	_update_transparency()

func _on_game_over():
	# En game over, solo mostramos el warning correspondiente
	var current = DopamineManager.get_current()
	if current < 0:
		_set_alpha_neg(1.0)
		_set_alpha_pos(0.0)
	else:
		_set_alpha_neg(0.0)
		_set_alpha_pos(1.0)

func _update_transparency():
	var current = DopamineManager.get_current()
	var target = DopamineManager.get_target()
	var maximum = DopamineManager.get_maxim()
	
	var alpha = 0.0
	
	if current < 0:
		# Valores negativos: activar SpriteNegativo
		_set_alpha_pos(0.0)  # Ocultar el positivo
		
		if current >= -target:
			# Valores negativos pero dentro del target: completamente transparente
			alpha = 0.0
		elif current <= -maximum:
			# En el máximo negativo (game over): completamente opaco
			alpha = 1.0
		else:
			# Fuera del target negativo pero antes del máximo: interpolación
			var distance_from_target = abs(current) - target
			var distance_range = maximum - target
			alpha = distance_from_target / distance_range
			alpha = clamp(alpha, 0.0, 1.0)
		
		_set_alpha_neg(alpha)
		
	else:
		# Valores positivos o cero: activar SpritePositivo
		_set_alpha_neg(0.0)  # Ocultar el negativo
		
		if current <= target:
			# Dentro del target: completamente transparente
			alpha = 0.0
		elif current >= maximum:
			# En el máximo positivo (game over): completamente opaco
			alpha = 1.0
		else:
			# Fuera del target positivo pero antes del máximo: interpolación
			var distance_from_target = current - target
			var distance_range = maximum - target
			alpha = distance_from_target / distance_range
			alpha = clamp(alpha, 0.0, 1.0)
		
		_set_alpha_pos(alpha)

func _set_alpha_neg(alpha: float):
	if sprite_neg:
		sprite_neg.modulate.a = alpha

func _set_alpha_pos(alpha: float):
	if sprite_pos:
		sprite_pos.modulate.a = alpha
