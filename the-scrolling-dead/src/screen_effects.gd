# ScreenEffects.gd
extends Control

@onready var dark_overlay: ColorRect = $DarkOverlay
@onready var stim_overlay: TextureRect = $ZombificationOverlay

# Parámetros ajustables
var max_alpha_dark: float = 0.95      # máxima opacidad para "sueño"
var max_alpha_stim: float = 0.95      # máxima opacidad para "overstim"
var easing_exponent: float = 2      # efecto empieza lento, sube rápido al final
var lerp_speed: float = 1

func _ready():
	DopamineManager.value_changed.connect(_update_effects)
	DopamineManager.target_changed.connect(_update_effects)
	dark_overlay.modulate.a = 0.0
	stim_overlay.modulate.a = 0.0

func _update_effects() -> void:
	var current = DopamineManager.get_current()
	var target = DopamineManager.get_target()
	var maximum = DopamineManager.get_maxim()
	var minimum = -maximum   # asumiendo simetría en tu diseño actual

	# safe guards
	if maximum <= 0:
		return

	# DEFAULT apagados (iremos activando solo uno)
	var desired_dark_a := 0.0
	var desired_stim_a := 0.0

	# --- caso 1: debajo del target -> sueño oscuro ---
	if current < target:
		# ratio en [0,1] donde 0=current==target y 1=current==minimum
		var denom = target - minimum   # target - (-maximum) = target + maximum
		if denom <= 0:
			denom = 1.0
		var raw = (target - current) / denom
		var ratio = clamp(raw, 0.0, 1.0)
		var eased = pow(ratio, easing_exponent)  # hace que el inicio sea lento
		desired_dark_a = eased * max_alpha_dark
		# asegurar overlay stim apagado
		desired_stim_a = 0.0

	# --- caso 2: encima del target -> overstimulation ---
	elif current > target:
		var denom = maximum - target
		if denom <= 0:
			denom = 1.0
		var raw = (current - target) / denom
		var ratio = clamp(raw, 0.0, 1.0)
		var eased = pow(ratio, easing_exponent)
		desired_stim_a = eased * max_alpha_stim
		desired_dark_a = 0.0

	# --- caso 3: exactamente en target -> todo apagado (ya lo cubre) ---

	# Aplicar suavizado con lerp para que no haya saltos
	dark_overlay.modulate.a = lerp(dark_overlay.modulate.a, desired_dark_a, lerp_speed)
	stim_overlay.modulate.a = lerp(stim_overlay.modulate.a, desired_stim_a, lerp_speed)
