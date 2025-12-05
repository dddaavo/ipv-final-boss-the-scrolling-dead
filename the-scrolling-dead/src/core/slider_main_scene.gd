extends Control

signal scrolled  # Retransmitir la señal del ScreensSlider interno
signal first_scroll  # Retransmitir señal de primer scroll
signal reset_requested  # Retransmitir señal de reset
signal minigame_banner_requested

@onready var slider = $ScreensSlider
@onready var bgm: AudioStreamPlayer = $ScreensSlider/BackgroundMusic
@onready var banner_label: Label = $MinigameBanner
@onready var banner_bg: ColorRect = $MinigameBannerBg
var _banner_tween: Tween

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
		slider.minigame_started.connect(_on_minigame_started)

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
	_hide_banner()

func _on_first_scroll():
	# Retransmitir la señal hacia arriba
	emit_signal("first_scroll")
	bgm.play()

func _on_reset_requested():
	# Retransmitir la señal hacia arriba
	emit_signal("reset_requested")


func _on_minigame_started(_page: Control):
	_show_lets_play_banner()
	emit_signal("minigame_banner_requested")


func _show_lets_play_banner():
	if not banner_label:
		return

	if _banner_tween:
		_banner_tween.kill()

	# Reset alpha and show both
	if banner_bg:
		banner_bg.modulate.a = 0.0
		banner_bg.show()
	banner_label.modulate.a = 0.0
	banner_label.show()

	_banner_tween = create_tween()
	if banner_bg:
		_banner_tween.tween_property(banner_bg, "modulate:a", 1.0, 0.25)
		_banner_tween.parallel().tween_property(banner_label, "modulate:a", 1.0, 0.25)
	else:
		_banner_tween.tween_property(banner_label, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_interval(0.6)
	if banner_bg:
		_banner_tween.tween_property(banner_bg, "modulate:a", 0.0, 0.25)
		_banner_tween.parallel().tween_property(banner_label, "modulate:a", 0.0, 0.25)
	else:
		_banner_tween.tween_property(banner_label, "modulate:a", 0.0, 0.25)
	_banner_tween.finished.connect(_hide_banner)


func _hide_banner():
	if not banner_label:
		return
	if _banner_tween:
		_banner_tween.kill()
		_banner_tween = null
	if banner_bg:
		banner_bg.modulate.a = 0.0
		banner_bg.hide()
	banner_label.modulate.a = 0.0
	banner_label.hide()
