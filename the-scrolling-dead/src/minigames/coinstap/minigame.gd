extends Control

@export var coin_scene: PackedScene
@onready var spawn_timer: Timer = Timer.new()
@export var pages: Control

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"Tap Coin!",
		"Las monedas doradas aumentan tu dopamina!!!
Pero cuidado con las rojas...",
		"#fyp #minigame #coins #fun")

	randomize()
	build_timer(spawn_timer, 0.25)
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

		var viewport_size = get_viewport_rect().size
		var random_x = randf_range(0, viewport_size.x)
		var random_y = randf_range(100, viewport_size.y - 600)

		coin.position = Vector2(random_x, random_y)

		var disappear_timer = Timer.new()
		disappear_timer.wait_time = 1.5
		disappear_timer.one_shot = true
		disappear_timer.autostart = true
		coin.add_child(disappear_timer)
		disappear_timer.timeout.connect(coin.queue_free)
