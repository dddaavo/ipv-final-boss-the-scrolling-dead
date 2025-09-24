extends Control

@onready var slider = $ScreensSlider
@onready var btn_next = $Button

func _ready() -> void:
	btn_next.pressed.connect(_on_next_pressed)

func _on_next_pressed() -> void:
	slider.go_next()
