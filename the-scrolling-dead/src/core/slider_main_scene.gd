extends Control

signal scrolled  # Retransmitir la señal del ScreensSlider interno

@onready var slider = $ScreensSlider

func _ready() -> void:
	# Conectar la señal del ScreensSlider y retransmitirla
	if slider:
		slider.scrolled.connect(_on_slider_scrolled)

func _on_slider_scrolled():
	# Retransmitir la señal hacia arriba
	emit_signal("scrolled")
