extends Control

signal scrolled
signal first_scroll  # Nueva señal para el primer scroll
var scrolling := false
signal reset_requested  # Nueva señal para resetear al segundo slide
signal minigame_started(page: Control)

@export var animation_time: float = 0.45
@export var pages: Control

# Pre-cargar todas las texturas manualmente para que funcione en HTML export
const SCREEN_TEXTURES := [
	preload("res://assets/screenSlider/0f1dbc9d-1c3a-490c-8e9f-a4197d854211.jpeg"),
	preload("res://assets/screenSlider/1.jpeg"),
	preload("res://assets/screenSlider/101ccf74-d379-420c-83c3-2c4b07196cec.jpeg"),
	preload("res://assets/screenSlider/11.jpeg"),
	preload("res://assets/screenSlider/2.jpeg"),
	preload("res://assets/screenSlider/2f80e031-c20f-48ad-a7c1-d2769c9e960a.jpeg"),
	preload("res://assets/screenSlider/3.jpeg"),
	preload("res://assets/screenSlider/5.jpeg"),
	preload("res://assets/screenSlider/5945c802-bd3e-427a-8433-60a745f126a3.jpeg"),
	preload("res://assets/screenSlider/6.jpeg"),
	preload("res://assets/screenSlider/7.jpeg"),
	preload("res://assets/screenSlider/78dc84cf-3480-4a51-96f2-095b5daebd2c.jpeg"),
	preload("res://assets/screenSlider/8.jpeg"),
	preload("res://assets/screenSlider/8757b5ad-2b0e-4e4e-be70-767d452ae188.jpeg"),
	preload("res://assets/screenSlider/8d0a33e0-d8f3-475c-a99d-c30e531637c3.jpeg"),
	preload("res://assets/screenSlider/8ed000f4-d130-49cc-b226-1ce5c9f0a7fb.jpeg"),
	preload("res://assets/screenSlider/90.jpeg"),
	preload("res://assets/screenSlider/9302df42-ff6b-46e2-8bb5-695a481e4c5e.jpeg"),
	preload("res://assets/screenSlider/989cfade-dc9a-4bfb-a838-7fa66ef5a187.jpeg"),
	preload("res://assets/screenSlider/a30c7dbd-7f1f-4b56-a32f-db343e0a5e2d.jpeg"),
	preload("res://assets/screenSlider/b38bd709-92ec-42db-bef5-1a08a6e179b0.jpeg"),
	preload("res://assets/screenSlider/b765dbe0-134e-446f-9734-b88760e7b046.jpeg"),
	preload("res://assets/screenSlider/c5b7d25c-b65e-4e41-8c48-28eb3ad4172a.jpeg"),
	preload("res://assets/screenSlider/c77534b4-f949-4875-98e2-ceecaba88166.jpeg"),
	preload("res://assets/screenSlider/cbcaa1c4-4c68-408d-b63e-1dcc48d53a43.jpeg"),
	preload("res://assets/screenSlider/cd3dec76-b5a8-4eef-a07f-387251494076.jpeg"),
	preload("res://assets/screenSlider/d4eae7d6-9193-4716-a5d0-31b4c780e347.jpeg"),
	preload("res://assets/screenSlider/dac08f05-2b5f-4711-8614-ba630dfce7aa.jpeg"),
	preload("res://assets/screenSlider/f17a28c9-3d9b-4261-8653-3442753fc3a3.jpeg"),
	preload("res://assets/screenSlider/f59a1a08-cbe4-4ea4-8fde-cab07616a9f4.jpeg"),
	preload("res://assets/screenSlider/gato.jpeg"),
	preload("res://assets/screenSlider/perro.jpg"),
	preload("res://assets/screenSlider/Sin título.jpeg"),
	preload("res://assets/screenSlider/tralalero.jpeg"),
]

@onready var start_game_sound = $StartGame
var screen_slider_textures: Array[Texture2D] = []
var _available_textures: Array[Texture2D] = []

var current_index := 0
var total_pages := 0
var game_started := false  # Nueva variable para controlar el inicio del juego
@onready var tutorial: Control = $Pages/Tutorial
var tutorial_removed := false  # Para saber si ya se eliminó el tutorial

var swipe_start_pos := Vector2.ZERO
var swipe_min_distance := 100.0
var swipe_active := false
@export var input_cooldown: float = 0.25
var last_input_time: float = -100.0

func _ready() -> void:
	clip_contents = true
	randomize()  

	total_pages = pages.get_child_count()
	_resize_pages()
	_position_pages_initial()
	_load_screen_slider_images()
	_apply_random_image_to_page(pages.get_child(0) if pages.get_child_count() > 0 else null)

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


func _load_screen_slider_images():
	# Usar texturas pre-cargadas (funciona tanto en desktop como HTML export)
	screen_slider_textures.assign(SCREEN_TEXTURES)
	
	# Inicializar bolsa aleatoria sin repetición
	_reset_texture_bag()


func _reset_texture_bag():
	_available_textures = screen_slider_textures.duplicate()
	if _available_textures.size() > 1:
		_available_textures.shuffle()


func _apply_random_image_to_page(page: Node):
	if page == null:
		return
	if page.is_in_group("minigame_page"):
		return
	if screen_slider_textures.is_empty():
		return
	if _available_textures.is_empty():
		_reset_texture_bag()
	if page is TextureRect:
		page.texture = _available_textures.pop_back()

func _position_pages_initial() -> void:
	pages.position = Vector2.ZERO
	current_index = 0
	if pages.get_child_count() > 0:
		_apply_random_image_to_page(pages.get_child(0))

func go_next() -> void:
	if total_pages == 0 or scrolling:
		return
	scrolling = true
	_prepare_next_page()
	await get_tree().process_frame

	var tween := create_tween()
	tween.tween_property(pages, "position:y", pages.position.y - size.y, animation_time) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(func():
		scrolling = false
		_on_scroll_finished()
	)
	scrolled.emit()


func _prepare_next_page() -> void:
	var last_child := pages.get_child(pages.get_child_count() - 1)
	var new_page_index := (current_index + 1) % total_pages
	var next_page := pages.get_child(new_page_index)
	_apply_random_image_to_page(next_page)

	next_page.position.y = last_child.position.y + size.y
	_refresh_page(next_page)


func _on_scroll_finished() -> void:
	current_index = (current_index + 1) % total_pages

	# Movemos el primer hijo al final (rotación circular real)
	var first_child := pages.get_child(0)
	pages.move_child(first_child, pages.get_child_count() - 1)

	for i in range(pages.get_child_count()):
		var child = pages.get_child(i)
		child.position.y = i * size.y

	pages.position.y = 0

	# Activar evento si la nueva página visible es un EventPage
	var current_page := pages.get_child(0)
	if current_page is EventPage:
		current_page.trigger_event_effect()

	# Emitir cuando la página visible es un minijuego
	if current_page.is_in_group("minigame_page"):
		emit_signal("minigame_started", current_page)


func _refresh_page(page: Control) -> void:
	if page.has_method("reset_content"):
		page.reset_content()
	else:
		page.queue_redraw()


func _on_ButtonNext_pressed() -> void:
	# Si es el primer scroll, emitir señal
	if not game_started:
		game_started = true
		first_scroll.emit()
		_remove_tutorial()
		start_game_sound.play()
	
	go_next()
	var diff := DopamineManager.get_difficulty_factor()
	var base_gain := randf_range(12, 40)  # variación baja al inicio
	var scaled_gain := base_gain * diff   # se vuelve más grande conforme sube la dificultad
	DopamineManager.increment(scaled_gain)

func _remove_tutorial():
	#Elimina el nodo Tutorial si existe
	if not tutorial_removed and pages:
		if tutorial:
			tutorial.queue_free()
			tutorial_removed = true
			# Recalcular el número de páginas
			await get_tree().process_frame
			total_pages = pages.get_child_count()
			_resize_pages()

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
