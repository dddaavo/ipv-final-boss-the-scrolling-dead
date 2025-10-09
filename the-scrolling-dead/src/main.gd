extends Node

@onready var score_manager = $Home/ScoreManager
@onready var score_screen = $ScoreScreen

func _ready() -> void:
	# Conectar señal de game over del score manager
	if score_manager:
		score_manager.game_over_with_score.connect(_on_game_over)
	
	# Conectar señal de retry del score screen
	if score_screen:
		score_screen.retry_pressed.connect(_on_retry_pressed)

func _on_game_over(final_score: int):
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
