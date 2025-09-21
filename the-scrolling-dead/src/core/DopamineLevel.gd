extends Node

class_name DopamineLevel

signal value_changed(new_value)

var current: float 
var target: float 
var maximum: float 

func set_current(value: float):
	var prev = current
	current = value
	if current != prev:
		emit_signal("value_changed", current)
		
func get_current() -> float:
	return current

func set_target(value: float):
	target = abs(value)

func set_maximum(value: float):
	maximum = abs(value)

func _init(_current: float, _target: float, _maximum: float):
	set_current(_current)
	set_target(_target)
	set_maximum(_maximum)

func add(value: float):
	set_current(current + value)
