extends DopamineEffect

class_name TargetModifierEffect

@export var modifier_value: float
var original_target: float

func _init(modifier: float, effect_duration: float = 0.0):
	super(effect_duration)
	modifier_value = modifier

func apply():
	original_target = DopamineManager.get_target()
	DopamineManager.increment_target(modifier_value)
	print("Applied target modifier: ", modifier_value, " for ", duration, " seconds")

func remove():
	DopamineManager.set_target(original_target)
	print("Removed target modifier, restored to: ", original_target)
	
func process_effect(delta_time: float):
	pass

func get_effect_type() -> String:
	return "TargetModifier"
