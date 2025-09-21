extends Node2D


func _on_inc_pressed() -> void:
	DopamineManager.increment(10) # Replace with function body.
	print(DopamineManager.is_on_target())
	print(DopamineManager.status())


func _on_dec_pressed() -> void:
	DopamineManager.decrement(10) # Replace with function body.
	print(DopamineManager.is_on_target())
	print(DopamineManager.status())
