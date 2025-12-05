extends TextureRect

const labelsScene := preload("res://src/ui/LabelsGroup.tscn")

func _ready() -> void:
	var labels_group = labelsScene.instantiate()
	add_child(labels_group)
	labels_group.set_texts(
		"Imagenes hermosas",
		"😍😍😍😍😍😍
😍😍😍😍😍😍",
		"#adorable #dog #snow #funny")
