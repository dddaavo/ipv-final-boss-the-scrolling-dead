extends Node2D

@onready var timer: Timer = Timer.new()

func _ready():
	DopamineManager.connect("game_over", Callable(self, "_on_dopamine_manager_game_over"))
	DopamineManager.connect("on_target", Callable(self, "_on_dopamine_manager_on_target"))
	DopamineManager.connect("target_changed", Callable(self, "_on_dopamine_manager_target_changed"))
	
	timer.wait_time = 2  # cada 2 segundos
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	DopamineManager.decrement(10)

func _on_inc_pressed() -> void:
	DopamineManager.increment(10)
	print(DopamineManager.is_on_target())
	print(DopamineManager.status())


func _on_dec_pressed() -> void:
	DopamineManager.decrement(10) 
	print(DopamineManager.is_on_target())
	print(DopamineManager.status())



func _on_dopamine_manager_game_over() -> void:
	print("Game over")

func _on_dopamine_manager_on_target() -> void:
	print("On target")
	
func _on_dopamine_manager_target_changed() -> void:
	print("Target Changed")
	print(DopamineManager.status())


func _on_inc_tgt_pressed() -> void:
	DopamineManager.increment_target(10)
	
	
func _on_dec_tgt_pressed() -> void:
	DopamineManager.decrement_target(10)
	
	
func _on_add_tgt_boost_pressed() -> void:
	DopamineManager.add_effect(TargetModifierEffect.new(200,5))
