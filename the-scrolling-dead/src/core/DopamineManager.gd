extends Node

signal game_over
signal on_target

@export var start: float
@export var target: float
@export var maxim: float


var dopamine_level: DopamineLevel

func _ready():
	dopamine_level = DopamineLevel.new(start,target,maxim)
	dopamine_level.connect("value_changed", Callable(self, "_on_value_changed"))

func increment(amount: float):
	dopamine_level.add(amount)

func decrement(amount: float):
	dopamine_level.add(-amount)

func _on_value_changed():
	_check_events()

func _check_events():
	if is_game_over():
		emit_signal("game_over")
	if is_on_target():
		emit_signal("on_target")

func is_game_over() -> bool:
	return abs(dopamine_level.current) >= dopamine_level.maximum

func is_on_target() -> bool:
	return abs(dopamine_level.current) >= dopamine_level.target
