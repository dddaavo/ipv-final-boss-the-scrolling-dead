extends Control

var questions = [
	{
		"question": "¿Cuál representa felicidad?",
		"correct": "res://src/minigames/guessemoji/assets/happy.png",
		"options": [
			"res://src/minigames/guessemoji/assets/happy.png",
			"res://src/minigames/guessemoji/assets/surprised.png",
			"res://src/minigames/guessemoji/assets/angry.png"
		]
	},
	{
		"question": "¿Cuál representa sorpresa?",
		"correct": "res://src/minigames/guessemoji/assets/surprised.png",
		"options": [
			"res://src/minigames/guessemoji/assets/happy.png",
			"res://src/minigames/guessemoji/assets/surprised.png",
			"res://src/minigames/guessemoji/assets/angry.png"
		]
	},
	{
		"question": "¿Cuál representa enojo?",
		"correct": "res://src/minigames/guessemoji/assets/angry.png",
		"options": [
			"res://src/minigames/guessemoji/assets/happy.png",
			"res://src/minigames/guessemoji/assets/surprised.png",
			"res://src/minigames/guessemoji/assets/angry.png"
		]
	}
]

var current_question

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	add_to_group("minigame_page")
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"EmojiQuiz",
		"¡Adivina el emoji!
¿Cuál es el estado de ánimo correcto?",
		"#emoji #minigame #fun #emotions")
		
	# Conectar las señales
	$Option1.pressed.connect(func(): _on_Option_pressed($Option1))
	$Option2.pressed.connect(func(): _on_Option_pressed($Option2))
	$Option3.pressed.connect(func(): _on_Option_pressed($Option3))
		
	_next_question()

func _next_question():
	current_question = questions.pick_random()
	$LabelQuestion.text = current_question.question

	var shuffled = current_question.options.duplicate()
	shuffled.shuffle()

	var option_buttons = [$Option1, $Option2, $Option3]
	for i in range(option_buttons.size()):
		option_buttons[i].texture_normal = load(shuffled[i])
		option_buttons[i].modulate = Color(1, 1, 1)  # Restablecer color

func _on_Option_pressed(button: TextureButton):
	var chosen_texture = button.texture_normal.resource_path

	if chosen_texture == current_question.correct:
		DopamineManager.increment(150)
		_flash_button(button, Color(0, 1, 0))
	else:
		DopamineManager.decrement(100)
		_flash_button(button, Color(1, 0, 0))
	
	await get_tree().create_timer(0.5).timeout
	_next_question()


func _flash_button(button: TextureButton, color: Color):
	var tween = create_tween()
	tween.tween_property(button, "modulate", color, 0.1)
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.3)
