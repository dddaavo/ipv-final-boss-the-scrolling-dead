extends Control

signal scrolled  # Retransmitir la señal del ScreensSlider interno
signal first_scroll  # Retransmitir señal de primer scroll
signal reset_requested  # Retransmitir señal de reset
signal minigame_banner_requested

@onready var slider = $ScreensSlider
@onready var bgm: AudioStreamPlayer = $ScreensSlider/BackgroundMusic
@onready var font_pixel: Font = load("res://fonts/PublicPixel.ttf")

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
	var banner := Label.new()
	banner.text = "¡A JUGAR!"
	if font_pixel:
		banner.add_theme_font_override("font", font_pixel)
	banner.add_theme_font_size_override("font_size", 64)
	banner.add_theme_constant_override("outline_size", 20)
	banner.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.set_anchors_preset(Control.PRESET_FULL_RECT)
	banner.modulate.a = 0.0
	add_child(banner)

	var tween := create_tween()
	tween.tween_property(banner, "modulate:a", 1.0, 0.25)
	tween.tween_interval(0.6)
	tween.tween_property(banner, "modulate:a", 0.0, 0.25)
	tween.finished.connect(banner.queue_free)
