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

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_coin_clicked()

func _on_coin_clicked() -> void:
	if is_good:
		DopamineManager.increment(100)
	else:
		DopamineManager.decrement(100)
	queue_free()
