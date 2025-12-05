extends Node

const VIDEO_ZOMBIFICACION := preload("uid://c3ca6js6dftsb")
const VIDEO_SLEEPY := preload("uid://1osua30h3bsb")

@onready var score_manager = $Home/ScoreManager
@onready var score_screen = $ScoreScreen
@onready var slider_main_scene = $SliderMainScene
@onready var game_over_video: VideoStreamPlayer = $GameOverVideo

signal retry_triggered

var game_started: bool = false
var final_score: float

@onready var user_status: Sprite2D = $MarcoCelular/FooterControl/UserStatus
@onready var bg_music = $SliderMainScene/ScreensSlider/BackgroundMusic

func _ready() -> void:
	#score_screen.pause_mode = Node.PROCESS_MODE_WHEN_PAUSED
	score_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_video.process_mode = Node.PROCESS_MODE_ALWAYS

	#$RetryButton.pause_mode = Node.PAUSE_MODE_PROCESS  # o donde esté el botón
	#$MarcoCelular.pause_mode = Node.PAUSE_MODE_PROCESS  # si también querés UI activa
	
	user_status.collapse_triggered.connect(_on_collapse)
	user_status.collapse_animation_finished.connect(_on_collapse_animation_finished)

	if score_screen and score_manager:
		score_screen.set_score_manager(score_manager)
	
	# Conectar señal de retry del score screen
	if score_screen:
		score_screen.retry_pressed.connect(_on_retry_pressed)
		score_screen.volver_menu_pressed.connect(_on_volver_menu_pressed)
	
	# Conectar señal de scroll directamente al score manager
	if slider_main_scene and score_manager:
		slider_main_scene.scrolled.connect(score_manager.add_scroll)
	
	# Conectar señal de primer scroll
	if slider_main_scene:
		slider_main_scene.first_scroll.connect(_on_first_scroll)
		slider_main_scene.reset_requested.connect(_on_reset_requested)


func _on_first_scroll():
	"""Manejar el primer scroll del juego"""
	# Iniciar DopamineManager
	if DopamineManager:
		DopamineManager.start_game()
	
	# Iniciar ScoreManager
	if score_manager and score_manager.has_method("start_game"):
		score_manager.start_game()


func _on_reset_requested():
	"""Manejar el reset - ir al segundo slide"""
	await get_tree().create_timer(0.1).timeout
	if slider_main_scene and slider_main_scene.has_node("ScreensSlider"):
		var screens_slider = slider_main_scene.get_node("ScreensSlider")
		if screens_slider.has_method("go_next"):
			screens_slider.go_next()
			# Marcar que el juego ha comenzado
			screens_slider.game_started = true
			# Después de ir al segundo slide, iniciar el juego automáticamente
			_on_first_scroll()


func _on_user_collapse(kind: String):
	var frame_index :int = kind == "low" if 0 else 6  # ejemplo según frames
	user_status.play_collapse_animation(frame_index, func():
		score_manager._on_game_over()   # <- acá disparás tu lógica real
	)


func _on_collapse(kind):
	# Esperar animación → NO TRIGGER GAME OVER TODAVÍA
	if kind == "low":
		user_status.play_collapse_animation(0)
	else:
		user_status.play_collapse_animation(6)


# ANIMACIÓN DE GAME OVER
func _on_collapse_animation_finished():
	get_tree().paused = true   # <- congela TODO el juego
	score_manager._on_game_over()
	final_score = score_manager.current_score
	var dopamine_value := DopamineManager.get_current() if DopamineManager else 0.0
	await wait_ignoring_pause(1.0)

	if bg_music.playing:
		bg_music.stop()

	DopamineManager.reset_game()
	user_status.visible = false
	game_over_video.visible = true

	# Elegir video según el nivel de dopamina al morir
	var chosen_video = VIDEO_ZOMBIFICACION
	if dopamine_value < 0:
		chosen_video = VIDEO_SLEEPY
	game_over_video.stream = chosen_video
	game_over_video.play()


func wait_ignoring_pause(seconds: float) -> void:
	var time_passed := 0.0
	while time_passed < seconds:
		await get_tree().process_frame
		time_passed += get_process_delta_time()  # este delta ignora pausa


func _on_retry_pressed():
	# Limpiar cualquier estado colgado de la ronda anterior
	get_tree().paused = false
	game_over_video.stop()
	game_over_video.visible = false
	user_status.visible = true
	user_status.reset_state()
	final_score = 0

	bg_music.play()

	# Resetear el DopamineManager (es un autoload, no se reinicia con la escena)
	if DopamineManager:
		DopamineManager.reset_game()

	# Resetear el score manager
	if score_manager:
		score_manager.reset_score()

	# Ocultar la pantalla de score
	if score_screen:
		score_screen.hide_score_screen()

	# Resetear el slider (esto emitirá la señal reset_requested)
	if slider_main_scene and slider_main_scene.has_node("ScreensSlider"):
		var screens_slider = slider_main_scene.get_node("ScreensSlider")
		if screens_slider.has_method("reset_to_start"):
			screens_slider.reset_to_start()

	emit_signal("retry_triggered")


func _on_game_over_video_finished() -> void:
	game_over_video.visible = false
	score_screen.show_score_screen(final_score)


func _on_volver_menu_pressed():
	get_tree().paused = false
	
	# Resetear el DopamineManager
	if DopamineManager:
		DopamineManager.reset_game()
	
	# Recargar la escena principal (menú)
	get_tree().change_scene_to_file("uid://c0wroa1sk1xif")
