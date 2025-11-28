extends TextureRect

@export var glitch_textures: Array[Texture2D]
@export var glitch_interval: float = 5.0
@export var glitch_duration: float = 0.5
@export var glitch_blinks: int = 4

var original_texture: Texture2D

func _ready():
	original_texture = texture
	glitch_loop()


func glitch_loop() -> void:
	while true:
		await get_tree().create_timer(glitch_interval).timeout
		await play_glitch_effect()


func play_glitch_effect() -> void:
	self.add_theme_color_override("panel", Color.BLACK)
	var glitch_tex = glitch_textures.pick_random()

	# PARPADEOS RÁPIDOS (blink)
	for i in range(glitch_blinks):
		# fade-out
		var t1 = create_tween()
		t1.tween_property(self, "modulate:a", 0.1, glitch_duration / (glitch_blinks * 2))
		await t1.finished

		self.texture = glitch_tex
		# fade-in
		var t2 = create_tween()
		t2.tween_property(self, "modulate:a", 1.0, glitch_duration / (glitch_blinks * 2))
		await t2.finished

		self.texture = original_texture
	# --- FADE SUAVE FINAL HACIA GLITCH
	var t3 = create_tween()
	t3.tween_property(self, "modulate:a", 0.0, glitch_duration / 2)
	await t3.finished

	self.texture = glitch_tex

	var t4 = create_tween()
	t4.tween_property(self, "modulate:a", 1.0, glitch_duration / 2)
	await t4.finished

	await get_tree().create_timer(0.1).timeout

	# volver a la textura original
	self.texture = original_texture
	self.remove_theme_color_override("panel")
