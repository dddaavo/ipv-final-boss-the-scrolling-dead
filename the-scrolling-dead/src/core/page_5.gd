extends TextureRect

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"The Dead Brain",
		"¡Hay que seguir scrolleando!
Tu cerebro te lo agradecerá...",
		"#happiness #game #brainrot #focus")
