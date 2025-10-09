extends Control

signal scrolled  # Nueva señal que se emite cada vez que se hace scroll

@export var animation_time: float = 0.45
@export var pages: Control
@onready var button_next: Button = $Button

var current_index: int = 0

func _ready() -> void:
	clip_contents = true
	
	if button_next:
		button_next.pressed.connect(_on_ButtonNext_pressed)
	
	_resize_pages()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("scroll"): _on_ButtonNext_pressed()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_resize_pages()
		pages.position = Vector2(0, -current_index * size.y)

func _resize_pages() -> void:
	# Hace que cada Page sea full-screen y las apila verticalmente
	var i: int = 0
	for child in pages.get_children():
		if child is Control:
			print("SIZE SCREENSLIDER", size)
			child.size = size
			child.position =Vector2(0, i * size.y)
		elif child is Node2D:
			child.position = Vector2(0, i * size.y)
			var scale_factor = Vector2(
				size.x / 480.0,   # ancho base de tu minijuego
				size.y / 720.0    # alto base de tu minijuego
			)
			child.scale = scale_factor
		
		i += 1 # TODO: Nro de páginas infinito - Generarlas
	pages.size = Vector2(size.x, size.y * i)


func go_next() -> void:
	# Avanza sólo hacia abajo (si hay más páginas)
	var count := pages.get_child_count()
	if current_index >= count - 1:
		return # en la última
	current_index += 1

	var vs := size
	var target := Vector2(0, -current_index * vs.y)

	# ANIMACIÓN
	var tw = create_tween()
	tw.tween_property(pages, "position", target, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_ButtonNext_pressed() -> void:
	go_next()
	var rand = randf_range(10,800)
	DopamineManager.increment(rand)
	DopamineManager.reset_effects()
	
	# Emitir señal de scroll para que ScoreManager la capture
	emit_signal("scrolled")
	
	print(rand)
