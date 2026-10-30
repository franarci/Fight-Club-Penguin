extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	var selector = load("res://src/ui/character_selection/character_select.tscn").instantiate()
	root.add_child(selector)
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	selector.activate_player_slot(-1)
	var card = selector.player_slots[0]
	assert(card.player_label.text == "Gunner")
	assert(not card.select_button.disabled)
	card.next()
	assert(card.player_label.text == "Demolisher")
	assert(not card.select_button.disabled)
	var image: Image = card.character.texture.get_image()
	assert(image.detect_alpha() != Image.ALPHA_NONE)
	assert(image.get_pixel(0, 0).a == 0.0)
	assert(image.get_pixel(image.get_width() - 1, 0).a == 0.0)
	for expected in ["Explorer", "Hunter"]:
		card.next()
		assert(card.player_label.text == expected)
		assert(card.select_button.disabled)
		assert(card.select_button.text == "Unavailable")
		assert(card.character.material.get_shader_parameter("saturation") == 0.0)
		card.confirm_character()
		card._on_select_pressed()
		assert(not card.is_ready)
		assert(not manager.get_player_by_device(-1).ready)
	var other = selector.player_slots[1]
	other.activate(0, 2)
	assert(other.player_label.text == "Gunner")
	assert(other.character.material != card.character.material)
	assert(other.character.material.get_shader_parameter("saturation") == 1.0)
	assert(card.character.material.get_shader_parameter("saturation") == 0.0)
	card.prev()
	card.prev()
	assert(card.player_label.text == "Demolisher")
	assert(not card.select_button.disabled)
	assert(card.character.material.get_shader_parameter("saturation") == 1.0)
	card.confirm_character()
	assert(card.is_ready)
	assert(manager.get_player_by_device(-1).character.key == "Demolisher")
	card.cancel_selection()
	card.cancel_selection()
	assert(card.player_label.text == "PRESS\nSTART")
	selector.free()
	manager.clear_players()
	print("PASS: transparent portrait, character names, unavailable selection blocked and independent grayscale")
	quit()
