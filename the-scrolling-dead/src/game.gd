extends Node

@onready var score_manager = $Home/ScoreManager
@onready var score_screen = $ScoreScreen
@onready var slider_main_scene = $SliderMainScene

var game_started: bool = false

func _ready() -> void:
	# Conectar señal de game over del score manager
	if score_manager:
		score_manager.game_over_with_score.connect(_on_game_over)
	
	# Conectar señal de retry del score screen
	if score_screen:
		score_screen.retry_pressed.connect(_on_retry_pressed)
	
	# Conectar señal de scroll directamente al score manager
	if slider_main_scene and score_manager:
		slider_main_scene.scrolled.connect(score_manager.add_scroll)
		
	call_deferred("start_game")
	
func start_game():
	if game_started:
		return
	game_started = true
	print("¡Juego empezado!")
	
	if DopamineManager:
		DopamineManager.reset_game()
	
	if score_manager:
		score_manager.reset_score()
	
	if score_screen:
		score_screen.hide_score_screen()

func _on_game_over(final_score: float):
	print("Game Over! Final Score: ", final_score)
	if score_screen:
		score_screen.show_score_screen(final_score)

func _on_retry_pressed():
	print("Restarting game...")
	
	# Resetear el DopamineManager (es un autoload, no se reinicia con la escena)
	if DopamineManager:
		DopamineManager.reset_game()
	
	# Resetear el score manager
	if score_manager:
		score_manager.reset_score()
	
	# Ocultar la pantalla de score
	if score_screen:
		score_screen.hide_score_screen()
	
	# Recargar la escena para reiniciar todo lo demás
	get_tree().reload_current_scene()
