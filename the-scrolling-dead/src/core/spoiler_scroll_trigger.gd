extends Node

## Este nodo observa los valores de DopamineManager y dispara
## "spoiler scrolls" cuando el jugador entra o permanece demasiado tiempo
## en el rango de sobreestimulación.

@export var slider: Control

# Intervalo entre repeticiones del spoiler scroll (en segundos)
@export var repeat_interval := 3

var low_dopamine := false
# Timer interno para repetir el spoiler scroll
@onready var repeat_spoiler_scroll_timer := Timer.new()

func _ready() -> void:
	# Conectar señales del DopamineManager
	DopamineManager.value_changed.connect(_on_dopamine_changed)
	DopamineManager.game_over.connect(_on_game_over)

	add_child(repeat_spoiler_scroll_timer)
	repeat_spoiler_scroll_timer.wait_time = repeat_interval
	repeat_spoiler_scroll_timer.one_shot = true
	repeat_spoiler_scroll_timer.timeout.connect(_on_repeat_timer_timeout)

func _on_dopamine_changed() -> void:
	_check_spoiler_trigger()

func _on_game_over() -> void:
	low_dopamine = false
	repeat_spoiler_scroll_timer.stop()

func _check_spoiler_trigger() -> void:
	var current = DopamineManager.get_current()
	var target = DopamineManager.get_target()
	var maximum = DopamineManager.get_maxim()

	if current < 0:
		if current >= -target or current <= -maximum:
			low_dopamine = false
			repeat_spoiler_scroll_timer.stop()
		else:
			if not low_dopamine:
				_trigger_spoiler_scroll()
				low_dopamine = true
				repeat_spoiler_scroll_timer.start()

func _trigger_spoiler_scroll() -> void:
	if slider:
		slider.spoiler_scroll()

func _on_repeat_timer_timeout() -> void:
	if low_dopamine:
		_trigger_spoiler_scroll()
		repeat_spoiler_scroll_timer.start()
