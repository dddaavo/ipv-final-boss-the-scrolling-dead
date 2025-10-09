extends Control

signal scrolled  # Retransmitir la señal del ScreensSlider interno

@onready var slider = $ScreensSlider
@onready var btn_next = $Button

func _ready() -> void:
	btn_next.pressed.connect(_on_next_pressed)
	
	# Conectar la señal del ScreensSlider y retransmitirla
	if slider:
		slider.scrolled.connect(_on_slider_scrolled)

func _on_slider_scrolled():
	# Retransmitir la señal hacia arriba
	emit_signal("scrolled")

func _on_next_pressed() -> void:
	slider.go_next()
