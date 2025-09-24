extends Area2D
class_name Coin

@export var good_texture: Texture2D
@export var bad_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var is_good: bool = true

func _ready() -> void:
	is_good = randi() % 2 == 0
	if is_good:
		sprite.texture = good_texture
	else:
		sprite.texture = bad_texture
