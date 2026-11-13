extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	var home = load("res://src/ui/home/Home.tscn").instantiate()
	get_tree().root.add_child(home)
	get_tree().current_scene = home
	var backdrop: Control = home.get_node("Background")
	assert(home.play_button.has_focus() and home.options_button.visible)
	assert(home.title_top.text == "FIGHT CLUB" and home.title_bottom.text == "PENGUIN")
	assert(home.title_top.get_theme_color("font_color").b > home.title_top.get_theme_color("font_color").r)
	assert(home.title_top.get_theme_color("font_shadow_color").r > 0.9)
	var sprite: TextureRect = backdrop.get_node("Penguin")
	assert(sprite.texture.get_image().detect_alpha() != Image.ALPHA_NONE)
	assert(sprite.texture.get_image().get_pixel(0, 0).a == 0.0)
	assert(backdrop.get_node("Snow").material is ShaderMaterial)
	assert(backdrop.get_node("Landscape").material is ShaderMaterial)
	for viewport_size in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(800, 600), Vector2i(640, 480)]:
		get_tree().root.size = viewport_size
		await settle()
		var bounds := Rect2(Vector2.ZERO, Vector2(viewport_size))
		for control in [home.title_top, home.title_bottom, home.play_button]:
			assert(bounds.encloses(control.get_global_rect()))
		assert(home.title_bottom.get_global_rect().end.y < home.play_button.get_global_rect().position.y)
		assert(home.play_button.get_global_rect().end.x < sprite.get_global_rect().position.x)
	get_tree().root.size = Vector2i(1152, 648)
	await settle()
	var title_position: Vector2 = home.title_top.global_position
	var button_position: Vector2 = home.play_button.global_position
	var scarf_phase: float = backdrop.get_node("Scarf").phase
	await get_tree().create_timer(0.2).timeout
	assert(backdrop.get_node("Scarf").phase != scarf_phase)
	assert(home.title_top.global_position == title_position and home.play_button.global_position == button_position)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var destination := OS.get_cmdline_user_args()[0]
		assert(get_viewport().get_texture().get_image().save_png(destination) == OK)
	home.play_button.pressed.emit()
	await settle()
	assert(get_tree().current_scene.name == "Main")
	get_tree().current_scene.free()
	PlayerManager.clear_players()
	print("PASS: polar assets/alpha, blue-red pixel title, responsive nonoverlapping layout, animated scarf, stable UI and Play transition")
	get_tree().quit()


func settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
