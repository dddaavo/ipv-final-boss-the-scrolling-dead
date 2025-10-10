extends Control

@export var main_scene: PackedScene

func _ready():
	$StartButton.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_packed(main_scene)
