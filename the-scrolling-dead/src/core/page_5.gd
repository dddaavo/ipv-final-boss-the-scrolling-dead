extends TextureRect

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"Imagen Vista 300 Veces",
		"Pero esta vez pega distinto...",
		"#repost #scrolling #samecontent #dopamine")
