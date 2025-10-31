extends Control

signal scrolled  # Retransmitir la señal del ScreensSlider interno
signal first_scroll  # Retransmitir señal de primer scroll
signal reset_requested  # Retransmitir señal de reset

@onready var slider = $ScreensSlider
@onready var bgm: AudioStreamPlayer = $ScreensSlider/BackgroundMusic


func _ready() -> void:
	var game = get_parent()
	if game.has_signal("game_over_triggered"):
		game.game_over_triggered.connect(_on_game_over_from_parent)
	if game.has_signal("retry_triggered"):
		game.retry_triggered.connect(_on_retry_from_parent)
	# Conectar las señales del ScreensSlider y retransmitirlas
	if slider:
		slider.scrolled.connect(_on_slider_scrolled)
		slider.first_scroll.connect(_on_first_scroll)
		slider.reset_requested.connect(_on_reset_requested)

func _on_game_over_from_parent(score: float) -> void:
	var tween = create_tween()
	tween.tween_property(bgm, "volume_db", -80, 1.0)  # Baja volumen en 1s
	tween.finished.connect(bgm.stop)

func _on_retry_from_parent() -> void:
	# Resetear el volumen y reproducir de nuevo
	bgm.volume_db = 0
	bgm.play()

func _on_slider_scrolled():
	# Retransmitir la señal hacia arriba
	emit_signal("scrolled")

func _on_first_scroll():
	# Retransmitir la señal hacia arriba
	emit_signal("first_scroll")
	bgm.play()

func _on_reset_requested():
	# Retransmitir la señal hacia arriba
	emit_signal("reset_requested")
