extends Node2D

func _ready():
	DopamineManager.connect("game_over", Callable(self, "_on_dopamine_manager_game_over"))
	DopamineManager.connect("on_target", Callable(self, "_on_dopamine_manager_on_target"))

func _on_inc_pressed() -> void:
	DopamineManager.increment(10) # Replace with function body.
	print(DopamineManager.is_on_target())
	print(DopamineManager.status())


func _on_dec_pressed() -> void:
	DopamineManager.decrement(10) # Replace with function body.
	print(DopamineManager.is_on_target())
	print(DopamineManager.status())


func _on_dopamine_manager_game_over() -> void:
	print("Game over")


func _on_dopamine_manager_on_target() -> void:
	print("On target")
