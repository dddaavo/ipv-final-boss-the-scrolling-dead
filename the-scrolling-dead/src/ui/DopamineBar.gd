extends TextureRect

@onready var indicator = $Indicator
@onready var target_zone = $Target

var bar_width: float
var center_position: float

func _ready():
	# Calcular dimensiones de la barra
	bar_width = size.x
	center_position = size.x / 2.0
	
	# Conectar a las señales del DopamineManager
	DopamineManager.connect("value_changed", Callable(self, "_on_dopamine_value_changed"))
	DopamineManager.connect("target_changed", Callable(self, "_on_targuet_value_changed"))
	
	# Actualizar tamaño inicial del target y posición del indicador
	_update_target_size()
	_update_indicator_position()

func _on_dopamine_value_changed():
	_update_indicator_position()
	
func _on_targuet_value_changed():
	_update_target_size()
	

func _update_target_size():
	var target_value = DopamineManager.get_target()  # dopamine_level.target
	var maximum = DopamineManager.get_maxim()       # dopamine_level.maximum
	
 # Calcular el ancho proporcional del target
	var target_ratio = target_value / maximum
	var target_width = target_ratio * bar_width
	
	# Actualizar el tamaño del target_zone
	target_zone.size.x = target_width
	
	# Centrar el target_zone
	target_zone.position.x = center_position - (target_width / 2.0)

func _update_indicator_position():
	var current_level = DopamineManager.get_current() 
	var maximum = DopamineManager.get_maxim()
	
	# Calcular posición relativa (-1 a 1)
	var normalized_value = current_level / maximum
	# Clamp para evitar que se salga de los límites
	normalized_value = clamp(normalized_value, -1.0, 1.0)
	
	# Convertir a posición en píxeles desde el centro
	var pixel_offset = normalized_value * (bar_width / 2.0)
	
	# Actualizar posición del indicador
	indicator.position.x = center_position + pixel_offset - (indicator.size.x / 2.0)
