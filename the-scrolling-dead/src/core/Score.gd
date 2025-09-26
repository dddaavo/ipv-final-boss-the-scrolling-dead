extends Node
class_name ScoreManager

signal score_changed(new_score: int)
signal high_score_achieved(new_high_score: int)
signal points_earned(points: int)

@export var points_per_second_in_target: int = 1
@export var bonus_multiplier_threshold: int = 100
@export var bonus_multiplier: float = 1
@export var save_file_path: String = "user://scores_history.save"
@export var max_scores_to_keep: int = 100  # Limitar para no llenar demasiado

var current_score: int = 0
var high_score: int = 0
var is_in_target: bool = false
var target_time_accumulated: float = 0.0
var current_multiplier: float = 1.0
var is_game_active: bool = true
var game_start_time: float
var scores_history: Array = []

func _ready():
	load_scores_data()
	_connect_dopamine_signals()
	_start_new_game()
	print("ScoreManager initialized - High Score: ", high_score)
	print("Total games played: ", scores_history.size())

func _process(delta):
	if is_game_active:
		_check_target_status()
		
		if is_in_target:
			target_time_accumulated += delta
			
			if target_time_accumulated >= 1.0:
				var points_to_add = int(points_per_second_in_target * current_multiplier)
				add_points(points_to_add)
				target_time_accumulated = 0.0
				$Label.text = str(get_score())

func _connect_dopamine_signals():
	if DopamineManager:
		DopamineManager.connect("game_over", Callable(self, "_on_game_over"))
		print("Connected to DopamineManager signals")
	else:
		print("Warning: DopamineManager not found")

func _start_new_game():
	game_start_time = Time.get_unix_time_from_system()
	is_game_active = true

func _check_target_status():
	var currently_in_target = DopamineManager.is_on_target()
	
	if currently_in_target != is_in_target:
		if currently_in_target:
			_on_target_entered()
		else:
			_on_target_exited()
		
		is_in_target = currently_in_target

func _on_target_entered():
	target_time_accumulated = 0.0
	print("Entered target zone - scoring started")

func _on_target_exited():
	print("Exited target zone - scoring paused")

func add_points(points: int):
	if not is_game_active:
		return
	
	current_score += points
	_update_multiplier()
	
	emit_signal("score_changed", current_score)
	emit_signal("points_earned", points)
	
	if current_score > high_score:
		high_score = current_score
		emit_signal("high_score_achieved", high_score)
		print("New High Score: ", high_score)
	
	print("Score: ", current_score, " (+", points, ") [x", current_multiplier, "]")

func _update_multiplier():
	var new_multiplier = 1.0 + (current_score / bonus_multiplier_threshold) * (bonus_multiplier - 1.0)
	if new_multiplier != current_multiplier:
		current_multiplier = new_multiplier
		print("Score multiplier updated: x", current_multiplier)

func _on_game_over():
	if not is_game_active:
		return  # Evitar múltiples game overs
	
	is_game_active = false
	is_in_target = false
	
	# Crear registro de la partida
	var game_record = {
		"score": current_score,
		"start_time": game_start_time,
		"end_time": Time.get_unix_time_from_system(),
		"duration": Time.get_unix_time_from_system() - game_start_time,
		"max_multiplier": current_multiplier,
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
	print("Game Duration: ", game_record.duration, " seconds")

func reset_score():
	current_score = 0
	current_multiplier = 1.0
	is_in_target = false
	target_time_accumulated = 0.0
	_start_new_game()
	emit_signal("score_changed", current_score)
	print("Score reset - New game started")

func get_score() -> int:
	return current_score

func get_high_score() -> int:
	return high_score

func get_multiplier() -> float:
	return current_multiplier

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
	return {
		"current_score": current_score,
		"high_score": high_score,
		"multiplier": current_multiplier,
		"is_scoring": is_scoring(),
		"points_per_second": int(points_per_second_in_target * current_multiplier)
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
