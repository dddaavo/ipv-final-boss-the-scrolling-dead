extends Node

@onready var back: Button = $Back
@onready var master_slider: HSlider = $VolumeControls/MasterVolume/MasterSlider
@onready var reels_slider: HSlider = $VolumeControls/ReelsVolume/ReelsSlider
@onready var sfx_slider: HSlider = $VolumeControls/SFXVolume/SFXSlider

var main = load("uid://c0wroa1sk1xif")

func _ready() -> void:
	# Cargar valores guardados o usar valores por defecto
	var master_volume = db_to_linear(AudioServer.get_bus_volume_db(0))
	var reels_volume = db_to_linear(AudioServer.get_bus_volume_db(1))
	var sfx_volume = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	master_slider.value = master_volume * 100
	reels_slider.value = reels_volume * 100
	sfx_slider.value = sfx_volume * 100

func _on_back_pressed() -> void:
	get_tree().change_scene_to_packed(main)

func _on_master_slider_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(0, volume_db)

func _on_reels_slider_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(1, volume_db)

func _on_sfx_slider_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(2, volume_db)
