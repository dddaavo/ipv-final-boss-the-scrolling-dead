extends DopamineEffect

class_name DecayAccelerationEffect

@export var base_decay_rate: float = 5.0
@export var decay_interval: float = 0.1
@export var acceleration_rate: float = 0.05  # Incremento del multiplicador por segundo
@export var max_multiplier: float = 3.0

var current_multiplier: float = 1.0
var accumulated_time: float = 0.0
var time_since_start: float = 0.0
var time_since_last_reset: float = 0.0

func _init(base_rate: float = 5.0, interval: float = 0.1, accel_rate: float = 0.05, max_mult: float = 3.0):
	super(0.0)  # Duración infinita (se maneja externamente)
	process = true
	base_decay_rate = base_rate
	decay_interval = interval
	acceleration_rate = accel_rate
	max_multiplier = max_mult
	
func update(delta_time: float):
	super(delta_time)
	time_since_start += delta_time
	time_since_last_reset += delta_time
	
	# Calcular el multiplicador basado en el tiempo desde el último reset
	current_multiplier = min(
		1.0 + (time_since_last_reset * acceleration_rate),
		max_multiplier
	)
	
func apply():
	current_multiplier = 1.0
	time_since_start = 0.0
	time_since_last_reset = 0.0
	accumulated_time = 0.0
	pass

func remove():
	pass

func process_effect(delta_time: float):
	accumulated_time += delta_time
	
	# Aplicar decay cuando se cumple el intervalo
	if accumulated_time >= decay_interval:
		var decay_amount = base_decay_rate * current_multiplier
		DopamineManager.decrement(decay_amount)
		accumulated_time = 0.0

func get_effect_type() -> String:
	return "DecayAccelerationEffect"

func get_current_multiplier() -> float:
	return current_multiplier

func get_time_since_reset() -> float:
	return time_since_last_reset
