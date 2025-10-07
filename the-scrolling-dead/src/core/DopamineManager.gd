extends Node

signal game_over
signal on_target
signal value_changed
signal target_changed

@export var start: float = 0
@export var target: float = 300
@export var maxim: float = 1000


var dopamine_level: DopamineLevel
var effect_manager: DopamineEffectManager

func _ready():
	dopamine_level = DopamineLevel.new(start,target,maxim)
	dopamine_level.connect("value_changed", Callable(self, "_on_value_changed"))
	dopamine_level.connect("target_changed", Callable(self, "_on_target_changed"))
	effect_manager = DopamineEffectManager.new()
	add_child(effect_manager)
	_apply_base_effects()	

func set_target(new_target: float):
	dopamine_level.set_target(new_target)

func set_maxim(new_max: float):
	dopamine_level.set_maxim(new_max)

func get_target() -> float:
	return dopamine_level.target

func get_current() -> float:
	return dopamine_level.current

func get_maxim() -> float:
	return dopamine_level.maximum
	
func increment_target(amount: float):
	dopamine_level.add_tgt(amount)
	
func decrement_target(amount: float):
	dopamine_level.add_tgt(-amount)

func increment(amount: float):
	dopamine_level.add(amount)

func decrement(amount: float):
	dopamine_level.add(-amount)

func _on_value_changed():
	emit_signal("value_changed")
	_check_events()

func _on_target_changed():
	emit_signal("target_changed")
	_check_events()

func _check_events():
	if is_game_over():
		emit_signal("game_over")
	if is_on_target():
		emit_signal("on_target")

func is_game_over() -> bool:
	return abs(dopamine_level.current) >= dopamine_level.maximum

func is_on_target() -> bool:
	return abs(dopamine_level.current) <= dopamine_level.target
	
func status() -> Array:
	return [dopamine_level.current, dopamine_level.target, dopamine_level.maximum]
	
	
func _apply_base_effects():
	# Crear el efecto de decay acelerado
	var decay_modifier_effect = DecayAccelerationEffect.new(
		5.0,   # base_decay_rate
		0.1,   # decay_interval
		0.4,  # acceleration_rate 
		10.0    # max_multiplier
	)
	effect_manager.add_effect(decay_modifier_effect)

func add_effect(effect: DopamineEffect):
	effect_manager.add_effect(effect)

func reset_effects():
	effect_manager.clear_all_effects()
	_apply_base_effects()
