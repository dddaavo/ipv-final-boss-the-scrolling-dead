extends Node

class_name DopamineEffectManager

var active_effects: Array[DopamineEffect] = []

func _ready():
	set_process(true) #activo el procesamiento en cada frame

func _process(delta):
	_update_active_effects(delta)

func _update_active_effects(delta_time: float):
	# Procesar todos los efectos activos
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		
		# Actualizar el efecto (duración, etc.)
		effect.update(delta_time)
			   
		# Procesar el efecto si lo necesita
		if effect.should_process():
			effect.process_effect(delta_time)
		
		# Remover efectos expirados
		if effect.is_expired():
			effect.on_expired()
			_remove_effect(effect)
			active_effects.remove_at(i)

func _remove_effect(effect: DopamineEffect):
	effect.is_active = false
	effect.remove()

func clear_all_effects():
	for effect in active_effects:
		_remove_effect(effect)
	active_effects.clear()
	print("All effects cleared")
	
func add_effect(effect: DopamineEffect):
	active_effects.append(effect)
	effect.apply()
	print("Added effect: ", effect.get_effect_type(), " - Total active effects: ", active_effects.size())
