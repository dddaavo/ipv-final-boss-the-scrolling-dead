@abstract
extends Node

class_name DopamineEffect

@export var duration: float = 0.0  # 0 = permanente hasta que se remueva manualmente
@export var remaining_time: float
var is_active: bool = false

func _init(effect_duration: float = 0.0):
	duration = effect_duration
	remaining_time = duration

# Métodos abstractos que deben ser implementados por las clases hijas}
@abstract
func apply()

@abstract
func remove()

# Métodos que pueden ser sobrescritos opcionalmente
func update(delta_time: float):
	if duration > 0:
		remaining_time -= delta_time

func should_process(delta_time: float) -> bool:
	# Por defecto, los efectos no procesan cada frame
	return false

func process_effect(delta_time: float):
	# Override para efectos que necesitan procesamiento continuo
	pass

func is_expired() -> bool:
	return duration > 0 and remaining_time <= 0

func get_effect_type() -> String:
	return "Unknown"

func on_expired():
	# Llamado justo antes de que el efecto sea removido por expiración
	pass
