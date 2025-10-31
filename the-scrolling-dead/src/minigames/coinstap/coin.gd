extends Area2D
class_name Coin

@export var good_texture: Texture2D
@export var bad_texture: Texture2D
@onready var sfx_click: AudioStreamPlayer = $SfxClick

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
		print("xddd")
		_on_coin_clicked()

func _on_coin_clicked() -> void:
	sfx_click.play()
	if is_good:
		DopamineManager.increment(100)
	else:
		DopamineManager.decrement(100)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(sprite, "scale", Vector2(0, 0), 0.4)

	tween.finished.connect(func ():
		await get_tree().create_timer(sfx_click.stream.get_length() - sfx_click.get_playback_position()).timeout
		queue_free()
	)
