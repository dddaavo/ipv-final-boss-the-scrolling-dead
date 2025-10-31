extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var main_scene: PackedScene
@export var option_scene: PackedScene
@export var credit_scene: PackedScene
@onready var full_screen_button: Button = $Button
@onready var start_button: Button = $StartButton  # asegúrate de tenerlo en la escena

var animating := false

func _ready():
	animated_sprite_2d.play()


func _on_start_button_pressed() -> void:
	if animating:
		return
	animating = true

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(animated_sprite_2d, "scale", animated_sprite_2d.scale * 1.3, 0.8)
	tween.parallel().tween_property(animated_sprite_2d, "modulate:a", 0.0, 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.9)
	
	tween.finished.connect(func ():
		get_tree().change_scene_to_packed(main_scene)
	)
	$ClickSound.play()
	

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
