extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var main_scene: PackedScene
@export var option_scene: PackedScene
@export var credit_scene: PackedScene
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var full_screen_button: Button = $Button



func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	animated_sprite_2d.play()

func _on_start_pressed():
	get_tree().change_scene_to_packed(main_scene)
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_packed(option_scene)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credit_scene)


func _on_button_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		full_screen_button.text = "Fullscreen"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		full_screen_button.text = "Exit Fullscreen"
