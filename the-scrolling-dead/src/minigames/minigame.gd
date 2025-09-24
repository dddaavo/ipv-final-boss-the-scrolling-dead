extends Node2D

@export var coin_scene: PackedScene
@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	randomize()

	build_timer(spawn_timer, 1.0)
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_coin)


func build_timer(timer: Timer, wait_time: float) -> void:
	timer.wait_time = wait_time
	timer.one_shot = false
	timer.autostart = true


func _spawn_coin() -> void:
	if coin_scene:
		var coin = coin_scene.instantiate()
		add_child(coin)

		var viewport_size = get_viewport().get_visible_rect().size
		var random_x = randf_range(0, viewport_size.x)
		var random_y = randf_range(0, viewport_size.y)
		coin.position = Vector2(random_x, random_y)

		var disappear_timer = Timer.new()
		disappear_timer.wait_time = 4.0
		disappear_timer.one_shot = true
		disappear_timer.autostart = true
		coin.add_child(disappear_timer)
		disappear_timer.timeout.connect(Callable(coin, "queue_free"))
