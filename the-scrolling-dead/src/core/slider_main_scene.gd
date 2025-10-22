extends Control

signal scrolled  # Retransmitir la señal del ScreensSlider interno
signal first_scroll  # Retransmitir señal de primer scroll
signal reset_requested  # Retransmitir señal de reset

@onready var slider = $ScreensSlider

func _ready() -> void:
	# Conectar las señales del ScreensSlider y retransmitirlas
	if slider:
		slider.scrolled.connect(_on_slider_scrolled)
		slider.first_scroll.connect(_on_first_scroll)
		slider.reset_requested.connect(_on_reset_requested)

func _on_slider_scrolled():
	# Retransmitir la señal hacia arriba
	emit_signal("scrolled")

func _on_first_scroll():
	# Retransmitir la señal hacia arriba
	emit_signal("first_scroll")

func _on_reset_requested():
	# Retransmitir la señal hacia arriba
	emit_signal("reset_requested")
