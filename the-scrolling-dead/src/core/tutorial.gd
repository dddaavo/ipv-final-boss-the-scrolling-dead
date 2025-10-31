extends Control

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"¿Cómo jugar?",
		"¡Mantén tu dopamina en equilibrio!
Scrollear aumenta la dopamina, así como los minijuegos
cuyas reglas están descriptas en cada 'caption'.
También hay eventos que pueden o no ayudarte... ¡Cuidado!",
		"#tutorial #minigames #dopamine #the-scrolling-dead")
