extends TextureRect

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"Galaxias",
		"Podemos sostener galaxias con nuestras manos?
O es sólo una imagen generada aleatoriamente con IA...?",
		"#galaxy #hand #pic #nonsense")
