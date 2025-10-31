extends Control
class_name EventPage

@onready var background: ColorRect = $Background
@onready var icon: TextureRect = $Icon
@onready var label_event: Label = $LabelEvent
@onready var good_sound: AudioStreamPlayer = $GoodSound
@onready var bad_sound: AudioStreamPlayer = $BadSound

var events = [
	{"text": "Tu publicación se vuelve viral", "dopamine": 300, "icon": "res://assets/events/viral.png"},
	{"text": "Recibes muchos likes de golpe", "dopamine": 200, "icon": "res://assets/events/likes.png"},
	{"text": "Te dejan un comentario negativo", "dopamine": -150, "icon": "res://assets/events/hate.png"},
	{"text": "Te cancelan por un mal post", "dopamine": -400, "icon": "res://assets/events/cancel.png"},
	{"text": "No pasa nada interesante hoy", "dopamine": -200, "icon": "res://assets/events/boring.png"},
	{"text": "Participas en una nueva tendencia", "dopamine": 150, "icon": "res://assets/events/trend.png"},
	{"text": "Decides desconectarte un rato", "dopamine": -100, "icon": "res://assets/events/offline.png"},
	{"text": "Tu cuenta fue shadowbaneada", "dopamine": -250, "icon": "res://assets/events/shadowban.png"}
]

var current_event = null
var triggered := false

func _ready() -> void:
	_prepare_random_event()

func _prepare_random_event() -> void:
	current_event = events.pick_random()
	label_event.text = current_event.text
	icon.texture = load(current_event.icon)
	background.color = Color(0.8, 0.1, 0.1, 0.15) if current_event.dopamine < 0 else Color(0.2, 0.6, 1.0, 0.15)

func trigger_event_effect() -> void:
	if triggered or not current_event:
		return
	triggered = true

	# Efecto Dopamine
	if current_event.dopamine > 0:
		DopamineManager.increment(current_event.dopamine)
		_play_sound(good_sound)
	else:
		DopamineManager.decrement(abs(current_event.dopamine))
		_play_sound(bad_sound)

func _play_sound(player: AudioStreamPlayer) -> void:
	if player && not player.playing:
		player.play()

func reset_content():
	triggered = false
	_prepare_random_event()
