@abstract
extends Node

class_name DopamineEffect

@export var duration: float = 0.0  # 0 = permanente hasta que se remueva manualmente
@export var remaining_time: float
var is_active: bool = false
var process: bool = false # Por defecto, los efectos no procesan cada frame

func _init(effect_duration: float = 0.0):
	duration = effect_duration
	remaining_time = duration

# Metodos one shoot	
@abstract
func apply()
@abstract
func remove()


# Metodos procesamiento continuo
func should_process() -> bool:
	return process

@abstract	
func process_effect(delta_time: float)
	
func update(delta_time: float):
	if duration > 0:
		remaining_time -= delta_time

func is_expired() -> bool:
	return duration > 0 and remaining_time <= 0

func on_expired():
	# Llamado justo antes de que el efecto sea removido por expiración
	pass

func get_effect_type() -> String:
	return "Undefined"
