extends Node

signal game_over
signal on_target
signal value_changed
signal target_changed

@export var start: float = 0
@export var target: float = 200
@export var maxim: float = 1000

@export var grace_seconds: float = 6.0
@export var ramp_seconds: float = 90.0
@export var difficulty_max: float = 2.5
@export var gain_influence: float = 0.35  # cuánto del multiplicador se aplica a las ganancias
@export var loss_influence: float = 0.35   # cuánto del multiplicador se aplica a las pérdidas
@export var difficulty_ease_power: float = 2.0  # >1: arranca suave, sube más al final

var dopamine_level: DopamineLevel
var effect_manager: DopamineEffectManager
var difficulty_elapsed: float = 0.0
var difficulty_active: bool = false
var allow_game_over: bool = false
var game_grace_until: float = 0.0  # ventana de gracia para evitar game over inmediato tras reset/start

func _ready():
	dopamine_level = DopamineLevel.new(start,target,maxim)
	dopamine_level.value_changed.connect(_on_value_changed)
	dopamine_level.target_changed.connect(_on_target_changed)
	effect_manager = DopamineEffectManager.new()
	add_child(effect_manager)
	_apply_base_effects()	
	set_process(true)

func _process(delta):
	if difficulty_active:
		difficulty_elapsed += delta

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
	var mult = _difficulty_multiplier()
	var applied_mult = lerp(1.0, mult, gain_influence)
	dopamine_level.add(amount * applied_mult)

func decrement(amount: float):
	var mult = _difficulty_multiplier()
	var applied_mult = lerp(1.0, mult, loss_influence)
	dopamine_level.add(-amount * applied_mult)

func _on_value_changed():
	emit_signal("value_changed")
	_check_events()

func _difficulty_multiplier() -> float:
	var t = max(0.0, difficulty_elapsed - grace_seconds) / max(ramp_seconds, 0.001)
	t = clamp(t, 0.0, 1.0)
	# Easing hacia el final: variación baja al inicio, crece luego
	var eased = pow(t, max(0.01, difficulty_ease_power))
	return lerp(1.0, difficulty_max, eased)

func get_difficulty_factor() -> float:
	return _difficulty_multiplier()
func _on_target_changed():
	emit_signal("target_changed")
	_check_events()

func _check_events():
	var now := Time.get_ticks_msec() / 1000.0
	if not allow_game_over:
		return
	if now < game_grace_until:
		return

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
		1.6,   # base_decay_rate
		0.35,   # decay_interval
		0.12,   # acceleration_rate 
		8.0   # max_multiplier
	)
	effect_manager.add_effect(decay_modifier_effect)

func add_effect(effect: DopamineEffect):
	effect_manager.add_effect(effect)

func reset_effects():
	effect_manager.clear_all_effects()
	_apply_base_effects()

func reset_game():
	# Resetear el nivel de dopamina a los valores iniciales
	dopamine_level.set_current(start)
	dopamine_level.set_target(target)
	dopamine_level.set_maximum(maxim)
	difficulty_elapsed = 0.0
	difficulty_active = false
	allow_game_over = false
	game_grace_until = Time.get_ticks_msec() / 1000.0 + 1.0
	
	# Resetear efectos
	reset_effects()
	
	# Pausar el juego hasta el primer scroll
	if effect_manager:
		effect_manager.stop_game()


func start_game():
	if effect_manager:
		effect_manager.start_game()
	difficulty_elapsed = 0.0
	difficulty_active = true
	allow_game_over = true
	game_grace_until = Time.get_ticks_msec() / 1000.0 + 0.5
