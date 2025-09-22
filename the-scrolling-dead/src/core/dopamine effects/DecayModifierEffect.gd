extends DopamineEffect

class_name DecayModifierEffect

@export var multiplier_value: float
@export var decay_interval: float = 1.0  # Cada cuánto tiempo aplica el decay
var accumulated_time: float = 0.0

func _init(multiplier: float, effect_duration: float = 0.0, interval: float = 1.0):
	super(effect_duration)
	process = true
	multiplier_value = multiplier
	decay_interval = interval

func update(delta_time: float):
	super(delta_time)
	# El procesamiento se hace en process_effect
	
func apply():
	print("Applied decay modifier: x", multiplier_value, " every ", decay_interval, "s for ", duration, " seconds")

func remove():
	print("Removed decay modifier: x", multiplier_value)

func process_effect(delta_time: float):
	accumulated_time += delta_time
	
	# Aplicar decay cuando se cumple el intervalo
	if accumulated_time >= decay_interval:
		var decay_amount = 5.0 * multiplier_value 
		DopamineManager.decrement(decay_amount)
		accumulated_time = 0.0
		print("Applied decay: -", decay_amount)

func get_effect_type() -> String:
	return "DecayModifierEffect"
