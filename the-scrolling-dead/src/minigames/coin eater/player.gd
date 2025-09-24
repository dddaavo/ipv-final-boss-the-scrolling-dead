extends Area2D

@export var speed = 600
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("coins"):
		var coin: Coin = area
		if coin.is_good:
			DopamineManager.increment(100)
		else:
			DopamineManager.decrement(10)
		coin.queue_free()
