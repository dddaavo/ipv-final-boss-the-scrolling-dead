extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@export var main_scene: PackedScene

func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	animated_sprite_2d.play()

func _on_start_pressed():
	get_tree().change_scene_to_packed(main_scene)
	
	
