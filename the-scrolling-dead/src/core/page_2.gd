extends TextureRect

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"Ocios Sanos",
		"¡Pasar horas frente a la PC es tan saludable
como estar con tu celular!",
		"#pc #funny #videogames #desinformation")
