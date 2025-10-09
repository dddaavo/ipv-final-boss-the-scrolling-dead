extends Control
class_name ScoreScreen

signal retry_pressed

@onready var current_score_label: Label = $Panel/MarginContainer/VBoxContainer/CurrentScoreContainer/CurrentScoreLabel
@onready var top_scores_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/TopScoresContainer
@onready var retry_button: Button = $Panel/MarginContainer/VBoxContainer/RetryButton
@onready var top10_message: Label = $Panel/MarginContainer/VBoxContainer/Top10Message

@export var top_font_size:int = 30

var last_final_score: float = 0.0
var pixel_font: Font = null

func _ready():
	retry_button.pressed.connect(_on_retry_button_pressed)
	if top10_message:
		top10_message.hide()
	
	# Cargar la fuente pixel
	pixel_font = load("res://fonts/PublicPixel.ttf")
	
	hide()

func show_score_screen(final_score: float):
	last_final_score = final_score
	
	# Mostrar puntaje actual con decimales y unidad Metros
	current_score_label.text = "%.1f Metros" % final_score
	
	# Cargar y mostrar top 10
	var top10_info = _display_top_scores(final_score)
	var is_in_top10 = top10_info["is_in_top10"]
	var player_position = top10_info["position"]
	
	# Mostrar mensaje personalizado según la posición
	if is_in_top10 and top10_message:
		if player_position == 0:
			top10_message.text = "🏆 ¡NUEVO RÉCORD! 🏆"
			top10_message.add_theme_color_override("font_color", Color.GOLD)
		elif player_position < 3:
			top10_message.text = "🎉 ¡Top " + str(player_position + 1) + "! ¡Increíble! 🎉"
			top10_message.add_theme_color_override("font_color", Color.ORANGE)
		else:
			top10_message.text = "⭐ ¡Entraste al TOP 10! ⭐"
			top10_message.add_theme_color_override("font_color", Color.GREEN_YELLOW)
		top10_message.show()
	elif top10_message:
		top10_message.hide()
	
	# Mostrar la pantalla
	show()

func _display_top_scores(current_final_score: float) -> Dictionary:
	# Limpiar scores previos
	for child in top_scores_container.get_children():
		child.queue_free()
	
	# Obtener top 10 desde ScoreManager
	var score_manager = get_node("/root/Main/Home/ScoreManager") if has_node("/root/Main/Home/ScoreManager") else null
	
	if not score_manager:
		print("Warning: ScoreManager not found")
		return {"is_in_top10": false, "position": -1}
	
	var top_scores = score_manager.get_top_scores(10)
	var is_in_top10 = false
	var latest_score_index = -1
	
	# Verificar si el puntaje actual está en el top 10
	# Buscar el score más reciente que coincida (el último agregado)
	var latest_time = 0.0
	for i in range(top_scores.size()):
		# Comparar floats con tolerancia
		if abs(top_scores[i].score - current_final_score) < 0.01:
			is_in_top10 = true
			var score_time = top_scores[i].get("end_time", 0.0)
			if score_time > latest_time:
				latest_time = score_time
				latest_score_index = i
	
	# Mostrar cada score
	for i in range(top_scores.size()):
		var score_entry = top_scores[i]
		var label = Label.new()
		
		# Aplicar la fuente pixel
		if pixel_font:
			label.add_theme_font_override("font", pixel_font)
		
		label.add_theme_font_size_override("font_size", top_font_size)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# Formato: "1. 150.5 MxS" con decimales
		var score_value = score_entry.score
		var score_text = str(i + 1) + ". " + ("%.1f Mxs" % score_value)
		
		# Determinar si es el score actual del jugador
		var is_current_player_score = (i == latest_score_index and abs(score_entry.score - current_final_score) < 0.01)
		
		# Agregar indicador si es el puntaje actual del jugador
		if is_current_player_score:
			score_text += " ⭐ TÚ"
		
		label.text = score_text
		
		# Resaltar según la posición y si es el jugador
		if is_current_player_score and i == 0:
			# Si es el jugador Y es el primer lugar: dorado brillante
			label.add_theme_color_override("font_color", Color.GOLD)
			label.add_theme_font_size_override("font_size", 38)
		elif is_current_player_score:
			# Si es el jugador pero no es primer lugar: verde brillante
			label.add_theme_color_override("font_color", Color.GREEN_YELLOW)
			label.add_theme_font_size_override("font_size", 36)
		elif i == 0:
			# Si es primer lugar pero no es el jugador: dorado normal
			label.add_theme_color_override("font_color", Color.GOLD)
		
		top_scores_container.add_child(label)
	
	# Si no hay scores, mostrar mensaje
	if top_scores.is_empty():
		var empty_label = Label.new()
		
		# Aplicar la fuente pixel
		if pixel_font:
			empty_label.add_theme_font_override("font", pixel_font)
		
		empty_label.add_theme_font_size_override("font_size", 60)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.text = "No hay puntajes aún"
		top_scores_container.add_child(empty_label)
	
	return {"is_in_top10": is_in_top10, "position": latest_score_index}

func _on_retry_button_pressed():
	emit_signal("retry_pressed")
	hide()

func hide_score_screen():
	hide()
