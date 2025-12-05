extends Control

@onready var label1: Label = $PageName
@onready var label2: Label = $PageDescription
@onready var label3: Label = $Hashtags

func set_texts(title: String, description: String, hashtags: String) -> void:
	label1.text = title
	label2.text = description
	label3.text = hashtags

	await get_tree().process_frame  # espera a que se actualice el tamaño del texto
	
	# Obtener alto de las labels
	var total_height = label1.size.y + label2.size.y
	
	# Margen inferior entre description y hashtags
	var margin = 20.0
	
	# Calcular nueva posición vertical para centrar el conjunto
	var hashtags_y = label3.position.y
	var offset_y = (hashtags_y - (total_height + margin))
	
	label1.position.y = offset_y
	label2.position.y = label1.position.y + label1.size.y + 4  # 4px de separación
