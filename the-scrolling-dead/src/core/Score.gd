extends Node
class_name ScoreManager

signal score_changed(new_score: int)
signal high_score_achieved(new_high_score: int)
signal points_earned(points: int)

@export var points_per_second_in_target: int = 1
@export var bonus_multiplier_threshold: int = 100
@export var bonus_multiplier: float = 1
@export var save_file_path: String = "user://score_data.save"

var current_score: int = 0
var high_score: int = 0
var is_in_target: bool = false
var target_time_accumulated: float = 0.0
var current_multiplier: float = 1.0
var is_game_active: bool = true

func _ready():
	load_high_score()
	_connect_dopamine_signals()
	print("ScoreManager initialized - High Score: ", high_score)

func _process(delta):
	if is_game_active:
		_check_target_status()
		
		if is_in_target:
			target_time_accumulated += delta
			
			# Otorgar puntos cada segundo
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

func _check_target_status():
	# Verificar directamente si está en target
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
	
	# Verificar nuevo high score
	if current_score > high_score:
		high_score = current_score
		save_high_score()
		emit_signal("high_score_achieved", high_score)
		print("New High Score: ", high_score)
	
	print("Score: ", current_score, " (+", points, ") [x", current_multiplier, "]")

func _update_multiplier():
	var new_multiplier = 1.0 + (current_score / bonus_multiplier_threshold) * (bonus_multiplier - 1.0)
	if new_multiplier != current_multiplier:
		current_multiplier = new_multiplier
		print("Score multiplier updated: x", current_multiplier)

func _on_game_over():
	is_game_active = false
	is_in_target = false
	save_high_score()
	print("Game Over - Final Score: ", current_score)

func reset_score():
	current_score = 0
	current_multiplier = 1.0
	is_in_target = false
	is_game_active = true
	target_time_accumulated = 0.0
	emit_signal("score_changed", current_score)
	print("Score reset")

func get_score() -> int:
	return current_score

func get_high_score() -> int:
	return high_score

func get_multiplier() -> float:
	return current_multiplier

func is_scoring() -> bool:
	return is_game_active and is_in_target

func save_high_score():
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"high_score": high_score,
			"timestamp": Time.get_unix_time_from_system()
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_high_score():
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
			else:
				print("Error parsing save file")
				high_score = 0
	else:
		high_score = 0
