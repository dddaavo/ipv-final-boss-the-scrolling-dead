extends Node
class_name ScoreManager

signal score_changed(new_score: float)
signal high_score_achieved(new_high_score: float)
signal meters_changed(meters: float)
signal seconds_changed(seconds: float)
signal game_over_with_score(final_score: float)

# Configuración del scoring
@export var save_file_path: String = "user://scores_history.save"
@export var max_scores_to_keep: int = 100

# Referencias a componentes
@onready var scroll_meter: ScrollMeter = $ScrollMeter

# Variables de puntuación
var total_seconds_in_target: float = 0.0  # Total de segundos en target
var current_score: float = 0.0  # metros × segundos
var high_score: float = 0.0

# Variables de estado del juego
var is_in_target: bool = false
var is_game_active: bool = false  # Empieza pausado
var game_started: bool = false  # Nueva variable para detectar primer scroll
var game_start_time: float
var scores_history: Array = []

func _ready():
	load_scores_data()
	_connect_dopamine_signals()
	_connect_scroll_meter_signals()
	_start_new_game()
	print("ScoreManager initialized - High Score: ", high_score)
	print("Total games played: ", scores_history.size())

func _process(delta):
	if is_game_active and game_started:
		_check_target_status()
		
		if is_in_target:
			# Acumular tiempo en target
			total_seconds_in_target += delta
			_update_display()

func _connect_dopamine_signals():
	if DopamineManager:
		DopamineManager.game_over.connect(_on_game_over)
		print("Connected to DopamineManager signals")
	else:
		print("Warning: DopamineManager not found")

func _connect_scroll_meter_signals():
	if scroll_meter:
		scroll_meter.meters_changed.connect(_on_scroll_meter_changed)
		print("Connected to ScrollMeter signals")
	else:
		print("Warning: ScrollMeter not found")

func _on_scroll_meter_changed(meters: float):
	"""Callback cuando el ScrollMeter actualiza los metros"""
	emit_signal("meters_changed", meters)
	_update_display()

func _start_new_game():
	game_start_time = Time.get_unix_time_from_system()
	is_game_active = false  # Esperar al primer scroll
	game_started = false
	total_seconds_in_target = 0.0
	current_score = 0
	
	# Resetear el scroll meter
	if scroll_meter:
		scroll_meter.reset()

func start_game():
	"""Llamar cuando el jugador haga el primer scroll"""
	if not game_started:
		game_started = true
		is_game_active = true
		game_start_time = Time.get_unix_time_from_system()
		print("Game started!")

func _check_target_status():
	var currently_in_target = DopamineManager.is_on_target()
	
	if currently_in_target != is_in_target:
		if currently_in_target:
			_on_target_entered()
		else:
			_on_target_exited()
		
		is_in_target = currently_in_target

func _on_target_entered():
	print("Entered target zone - scoring started")

func _on_target_exited():
	print("Exited target zone - scoring paused")

func add_scroll():
	"""Llamar esta función cada vez que el jugador haga scroll"""
	if not is_game_active:
		return
	
	# Delegar al ScrollMeter
	if scroll_meter:
		scroll_meter.register_scroll()

func _update_display():
	$Segundos.text = "%.0fs" % total_seconds_in_target
	$Metros.text = "%.1fm" % scroll_meter.get_total_meters()

func _calculate_final_score() -> float:
	"""Calcula el score final como metros × segundos"""
	var meters = scroll_meter.get_total_meters() if scroll_meter else 0.0
	return meters * total_seconds_in_target

func add_points(_points: int):
	"""Función legacy - ya no se usa el sistema de puntos directos"""
	pass

func _on_game_over():
	if not is_game_active:
		return  # Evitar múltiples game overs
	
	is_game_active = false
	is_in_target = false
	
	# Calcular el score final
	current_score = _calculate_final_score()
	
	# Actualizar high score si es necesario
	if current_score > high_score:
		high_score = current_score
		emit_signal("high_score_achieved", high_score)
	
	# Crear registro de la partida
	var meters = scroll_meter.get_total_meters() if scroll_meter else 0.0
	var game_record = {
		"score": current_score,
		"meters": meters,
		"seconds_in_target": total_seconds_in_target,
		"start_time": game_start_time,
		"end_time": Time.get_unix_time_from_system(),
		"duration": Time.get_unix_time_from_system() - game_start_time,
		"date": Time.get_datetime_string_from_system(),
		"was_high_score": current_score == high_score
	}
	
	# Agregar al historial
	scores_history.append(game_record)
	
	# Mantener solo los últimos N scores
	if scores_history.size() > max_scores_to_keep:
		scores_history = scores_history.slice(-max_scores_to_keep)
	
	save_scores_data()
	print("Game Over - Final Score: ", current_score)
	print("Meters: %.1f, Seconds in target: %.1f" % [meters, total_seconds_in_target])
	print("Game Duration: ", game_record.duration, " seconds")
	
	# Emitir señal con el puntaje final
	emit_signal("game_over_with_score", current_score)

func reset_score():
	current_score = 0
	total_seconds_in_target = 0.0
	is_in_target = false
	_start_new_game()
	emit_signal("score_changed", current_score)
	print("Score reset - New game started")

func get_score() -> float:
	return _calculate_final_score()

func get_high_score() -> float:
	return high_score

func get_meters() -> float:
	return scroll_meter.get_total_meters() if scroll_meter else 0.0

func get_seconds_in_target() -> float:
	return total_seconds_in_target

func is_scoring() -> bool:
	return is_game_active and is_in_target

func save_scores_data():
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"high_score": high_score,
			"scores_history": scores_history,
			"total_games": scores_history.size(),
			"last_updated": Time.get_datetime_string_from_system()
		}
		save_file.store_string(JSON.stringify(save_data, "\t"))  # Con indentación para legibilidad
		save_file.close()
		print("Scores data saved (", scores_history.size(), " games)")

func load_scores_data():
	if FileAccess.file_exists(save_file_path):
		var save_file = FileAccess.open(save_file_path, FileAccess.READ)
		if save_file:
			var json_text = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			
			if parse_result == OK:
				var save_data = json.data
				high_score = save_data.get("high_score", 0)
				scores_history = save_data.get("scores_history", [])
				print("Loaded ", scores_history.size(), " game records")
			else:
				print("Error parsing save file")
				_initialize_empty_data()
	else:
		_initialize_empty_data()

func _initialize_empty_data():
	high_score = 0
	scores_history = []

func get_score_info() -> Dictionary:
	var meters = scroll_meter.get_total_meters() if scroll_meter else 0.0
	return {
		"current_score": _calculate_final_score(),
		"high_score": high_score,
		"meters": meters,
		"seconds_in_target": total_seconds_in_target,
		"is_scoring": is_scoring()
	}

# Nuevos métodos para obtener estadísticas del historial
func get_total_games() -> int:
	return scores_history.size()

func get_average_score() -> float:
	if scores_history.is_empty():
		return 0.0
	
	var total = 0
	for game in scores_history:
		total += game.score
	
	return float(total) / scores_history.size()

func get_total_playtime() -> float:
	var total_time = 0.0
	for game in scores_history:
		total_time += game.get("duration", 0.0)
	return total_time

func get_top_scores(count: int = 10) -> Array:
	var sorted_scores = scores_history.duplicate()
	sorted_scores.sort_custom(func(a, b): return a.score > b.score)
	return sorted_scores.slice(0, min(count, sorted_scores.size()))

func get_recent_scores(count: int = 10) -> Array:
	var recent = scores_history.slice(-count) if scores_history.size() > count else scores_history
	recent.reverse()  # Más recientes primero
	return recent

func get_stats_summary() -> Dictionary:
	return {
		"total_games": get_total_games(),
		"high_score": high_score,
		"average_score": get_average_score(),
		"total_playtime": get_total_playtime(),
		"last_game": scores_history[-1] if not scores_history.is_empty() else null
	}

# Métodos de debug y utilidad
func print_stats():
	var stats = get_stats_summary()
	print("=== SCORE STATISTICS ===")
	print("Total Games: ", stats.total_games)
	print("High Score: ", stats.high_score)
	print("Average Score: ", "%.1f" % stats.average_score)
	print("Total Playtime: ", "%.1f" % stats.total_playtime, " seconds")

func export_scores_to_text() -> String:
	var text = "Game Scores History\n"
	text += "==================\n\n"
	
	var stats = get_stats_summary()
	text += "Summary:\n"
	text += "- Total Games: " + str(stats.total_games) + "\n"
	text += "- High Score: " + str(stats.high_score) + "\n"
	text += "- Average Score: " + ("%.1f" % stats.average_score) + "\n"
	text += "- Total Playtime: " + ("%.1f" % stats.total_playtime) + " seconds\n\n"
	
	text += "Recent Games:\n"
	text += "-------------\n"
	
	var recent = get_recent_scores(20)
	for i in range(recent.size()):
		var game = recent[i]
		text += str(i + 1) + ". Score: " + str(game.score)
		text += " | Duration: " + ("%.1f" % game.duration) + "s"
		text += " | Date: " + str(game.date)
		if game.get("was_high_score", false):
			text += " [HIGH SCORE!]"
		text += "\n"
	
	return text

func clear_all_scores():
	scores_history.clear()
	high_score = 0
	save_scores_data()
	print("All scores cleared")
