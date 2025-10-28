extends Node

@onready var score_manager = $Home/ScoreManager
@onready var score_screen = $ScoreScreen
@onready var slider_main_scene = $SliderMainScene
@onready var game_over_video: VideoStreamPlayer = $GameOverVideo

var game_started: bool = false
var final_score: float

func _ready() -> void:
	# Pass ScoreManager reference to ScoreScreen
	if score_screen and score_manager:
		score_screen.set_score_manager(score_manager)
	
	# Conectar señal de game over del score manager
	if score_manager:
		score_manager.game_over_with_score.connect(_on_game_over)
	
	# Conectar señal de retry del score screen
	if score_screen:
		score_screen.retry_pressed.connect(_on_retry_pressed)
	
	# Conectar señal de scroll directamente al score manager
	if slider_main_scene and score_manager:
		slider_main_scene.scrolled.connect(score_manager.add_scroll)
	
	# Conectar señal de primer scroll
	if slider_main_scene:
		slider_main_scene.first_scroll.connect(_on_first_scroll)
		slider_main_scene.reset_requested.connect(_on_reset_requested)

func _on_first_scroll():
	"""Manejar el primer scroll del juego"""
	print("First scroll detected - Starting game!")
	
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

		

func _on_game_over(score: float):
	game_over_video.visible = true
	game_over_video.play()
	final_score = score

func _on_retry_pressed():
	
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
	


func _on_game_over_video_finished() -> void:
	game_over_video.visible = false
	score_screen.show_score_screen(final_score)
