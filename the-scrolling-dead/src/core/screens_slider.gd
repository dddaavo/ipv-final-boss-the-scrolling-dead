extends Control

signal scrolled
signal first_scroll  # Nueva señal para el primer scroll
signal reset_requested  # Nueva señal para resetear al segundo slide

@export var animation_time: float = 0.45
@export var pages: Control

var current_index := 0
var total_pages := 0
var game_started := false  # Nueva variable para controlar el inicio del juego

var swipe_start_pos := Vector2.ZERO
var swipe_min_distance := 100.0
var swipe_active := false
@export var input_cooldown: float = 1
var last_input_time: float = -100.0

func _ready() -> void:
	clip_contents = true

	total_pages = pages.get_child_count()
	_resize_pages()
	_position_pages_initial()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_resize_pages()
		_position_pages_initial()

func _resize_pages() -> void:
	var i := 0
	for child in pages.get_children():
		if child is Control:
			child.size = size
			child.position = Vector2(0, i * size.y)
			i += 1
	pages.size = size * Vector2(1, total_pages)

func _position_pages_initial() -> void:
	pages.position = Vector2.ZERO
	current_index = 0

func go_next() -> void:
	if total_pages == 0:
		return

	# "RENDER" de siguiente página
	_prepare_next_page()

	var start_y := pages.position.y
	var end_y := start_y - size.y

	var tween := create_tween()
	tween.tween_property(pages, "position:y", end_y, animation_time) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	tween.finished.connect(_on_scroll_finished)
	emit_signal("scrolled")

func _prepare_next_page() -> void:
	var last_child := pages.get_child(pages.get_child_count() - 1)
	var new_page_index := (current_index + 1) % total_pages
	var next_page := pages.get_child(new_page_index)

	next_page.position.y = last_child.position.y + size.y
	_refresh_page(next_page)

	await get_tree().process_frame


func _on_scroll_finished() -> void:
	current_index = (current_index + 1) % total_pages

	# Movemos el primer hijo al final (rotación circular real)
	var first_child := pages.get_child(0)
	pages.move_child(first_child, pages.get_child_count() - 1)

	for i in range(pages.get_child_count()):
		var child = pages.get_child(i)
		child.position.y = i * size.y

	pages.position.y = 0


func _refresh_page(page: Control) -> void:
	if page.has_method("reset_content"):
		page.reset_content()
	else:
		page.queue_redraw()


func _on_ButtonNext_pressed() -> void:
	# Si es el primer scroll, emitir señal
	if not game_started:
		game_started = true
		emit_signal("first_scroll")
	
	go_next()
	var rand = randf_range(25, 300)
	DopamineManager.increment(rand)

func reset_to_start():
	"""Resetea el slider pero va al segundo slide"""
	game_started = false
	_position_pages_initial()
	# Emitir señal para que el manager maneje la lógica
	emit_signal("reset_requested")


func _input(event: InputEvent) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_input_time < input_cooldown:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_trigger_next()
		last_input_time = now

	elif event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_pos = event.position
			swipe_active = true
		else:
			swipe_active = false

	elif event is InputEventScreenDrag and swipe_active:
		var delta = event.position - swipe_start_pos
		if abs(delta.y) > swipe_min_distance:
			if delta.y < 0:
				_trigger_next()
				last_input_time = now
			swipe_active = false

func _trigger_next() -> void:
	_on_ButtonNext_pressed()
