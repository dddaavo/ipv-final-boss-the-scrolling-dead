extends Control

signal scrolled

@export var max_pages := 4
var page_index := 0

@export var animation_time: float = 0.45
@export var pages: Control
@onready var button_next: Button = $Button

var current_index: int = 0

var swipe_start_pos: Vector2
var swipe_min_distance := 100.0
var swipe_active := false

func _ready() -> void:
	clip_contents = true

	if button_next:
		button_next.pressed.connect(_on_ButtonNext_pressed)

	_resize_pages()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_resize_pages()
		pages.position = Vector2(0, -current_index * size.y)

func _resize_pages() -> void:
	var i: int = 0
	for child in pages.get_children():
		if child is Control:
			child.size = size
			child.position = Vector2(0, i * size.y)
			i += 1
	pages.size = size

func go_next() -> void:
	current_index = (current_index + 1) % max_pages
	page_index += 1

	var start_y := pages.position.y
	var end_y := pages.position.y - size.y

	var tween := create_tween()
	tween.tween_property(pages, "position:y", end_y, animation_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_scroll_finished)

func _on_scroll_finished() -> void:
	pages.position.y = 0

	for child in pages.get_children():
		child.position.y -= size.y

	for child in pages.get_children():
		if child.position.y < -size.y * 0.5:
			child.position.y += size.y * max_pages
			_refresh_page(child)

func _refresh_page(page: Control) -> void:
	if page.has_method("reset_content"):
		page.reset_content()

func _on_ButtonNext_pressed() -> void:
	go_next()
	var rand = randf_range(10, 800)
	DopamineManager.increment(rand)
	emit_signal("scrolled")
	print(rand)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_on_ButtonNext_pressed()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start_pos = event.position
			swipe_active = true
		else:
			swipe_active = false

	elif event is InputEventScreenDrag and swipe_active:
		var delta = event.position - swipe_start_pos
		if abs(delta.y) > swipe_min_distance:
			if delta.y < 0:
				_on_ButtonNext_pressed()
			swipe_active = false
