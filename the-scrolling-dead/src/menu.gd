extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var main_scene: PackedScene
@export var option_scene: PackedScene
@export var credit_scene: PackedScene
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	animated_sprite_2d.play()

func _on_start_pressed():
	get_tree().change_scene_to_packed(main_scene)
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_packed(option_scene)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credit_scene)
