extends Control

@onready var label1: Label = $PageName
@onready var label2: Label = $PageDescription
@onready var label3: Label = $Hashtags

func set_texts(title: String, description: String, hashtags: String) -> void:
	label1.text = title
	label2.text = description
	label3.text = hashtags
