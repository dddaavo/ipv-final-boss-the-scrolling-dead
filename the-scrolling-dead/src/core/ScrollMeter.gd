extends Node
class_name ScrollMeter

## Componente para medir metros de scrolleo
##
## Este componente convierte los scrolls del jugador en metros recorridos,
## basándose en un promedio configurable de centímetros por pantalla.

signal meters_changed(total_meters: float)
signal scroll_registered(scroll_count: int)

## Centímetros promedio que ocupa cada pantalla (altura de pantalla móvil)
## Por defecto: 15 cm (aproximado de un móvil de 6 pulgadas)
@export var cm_per_screen: float = 15.0

## Número de scrolls que representan una pantalla completa
## Por defecto: 1 scroll = 1 pantalla
@export var scrolls_per_screen: float = 1.0

# Variables internas
var total_scrolls: int = 0  # Contador de scrolls totales
var total_meters: float = 0.0  # Metros acumulados
var meters_per_scroll: float = 0.0  # Se calcula en _ready

func _ready() -> void:
	_calculate_meters_per_scroll()
	print("ScrollMeter initialized:")
	print("  - cm per screen: %.2f cm" % cm_per_screen)
	print("  - scrolls per screen: %.2f" % scrolls_per_screen)
	print("  - meters per scroll: %.4f m" % meters_per_scroll)

func _calculate_meters_per_scroll() -> void:
	# Calcula cuántos metros representa cada scroll individual
	# Convertir cm a metros y dividir por scrolls necesarios para una pantalla
	meters_per_scroll = (cm_per_screen / 100.0) / scrolls_per_screen

## Registra un scroll y actualiza los metros acumulados
func register_scroll() -> void:
	total_scrolls += 1
	total_meters += meters_per_scroll
	
	scroll_registered.emit(total_scrolls)
	meters_changed.emit(total_meters)

## Registra múltiples scrolls a la vez
func register_scrolls(count: int) -> void:
	if count <= 0:
		return
	
	total_scrolls += count
	total_meters += meters_per_scroll * count
	
	scroll_registered.emit(total_scrolls)
	meters_changed.emit(total_meters)

## Obtiene el total de metros acumulados
func get_total_meters() -> float:
	return total_meters

## Obtiene el total de scrolls registrados
func get_total_scrolls() -> int:
	return total_scrolls

## Obtiene cuántos metros representa cada scroll
func get_meters_per_scroll() -> float:
	return meters_per_scroll

## Resetea el contador de scrolls y metros
func reset() -> void:
	total_scrolls = 0
	total_meters = 0.0
	meters_changed.emit(total_meters)
	scroll_registered.emit(total_scrolls)
	print("ScrollMeter reset")

## Actualiza la configuración y recalcula el valor por scroll
func update_configuration(new_cm_per_screen: float, new_scrolls_per_screen: float) -> void:
	cm_per_screen = new_cm_per_screen
	scrolls_per_screen = new_scrolls_per_screen
	_calculate_meters_per_scroll()
	print("ScrollMeter configuration updated - meters per scroll: %.4f m" % meters_per_scroll)
