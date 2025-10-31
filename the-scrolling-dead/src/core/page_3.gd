extends TextureRect

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"Scrolling Dream",
		"¡Nada mejor antes de ir a dormir
que scrollear con el celular!",
		"#smartphone #scrolling #social #dopamine")
