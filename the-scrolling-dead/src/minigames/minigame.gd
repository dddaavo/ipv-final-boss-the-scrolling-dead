extends Node2D

@export var coin_scene: PackedScene
@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	spawn_timer.wait_time = 1.0  # cada 1 segundo
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_coin)

func _spawn_coin() -> void:
	if coin_scene:
		var coin = coin_scene.instantiate()
		add_child(coin)

		var viewport_size = get_viewport().get_visible_rect().size
		var random_x = randf_range(0, viewport_size.x)
		var random_y = randf_range(0, viewport_size.y)

		coin.position = Vector2(random_x, random_y)
