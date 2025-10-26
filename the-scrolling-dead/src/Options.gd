extends Node

@onready var back: Button = $Back
var main = load("uid://c0wroa1sk1xif")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(main)
