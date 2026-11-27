extends Node

func _ready() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	PlayerManager.clear_players()
	for device in range(3):
		MultiplayerInput.device_actions[device] = {}
		for action in MultiplayerInput.core_actions:
			MultiplayerInput.device_actions[device][action] = action
	var selection = load("res://src/ui/character_selection/character_select.tscn").instantiate()
	get_tree().root.add_child(selection)
	selection.set_process(false)
	for card in selection.player_slots:
		card.set_process(false)
		assert(not card.arena_preview.visible)
		assert(not card.preview_area.visible)
	await get_tree().process_frame
	await get_tree().process_frame
	for card in selection.player_slots:
		assert(is_equal_approx(card.card_panel.size.y, card.size.y))
	selection.activate_player_slot(-1)
	await get_tree().process_frame
	await get_tree().process_frame
	var active_card: PlayerSelection = selection.player_slots[0]
	var empty_card: PlayerSelection = selection.player_slots[1]
	assert(active_card.preview_area.visible and not empty_card.preview_area.visible)
	assert(active_card.card_panel.size.y < empty_card.card_panel.size.y)
	assert(is_equal_approx(empty_card.card_panel.size.y, empty_card.size.y))
	assert(is_equal_approx(active_card.size.x, empty_card.size.x))
	for slot in range(1, 4):
		selection.activate_player_slot(slot - 1)
	for character_index in range(4):
		for slot in range(4):
			var card: PlayerSelection = selection.player_slots[slot]
			card.selected_character = character_index
			card.update_character_preview()
			var preview = card.arena_preview
			var penguin: Penguin = preview.penguin
			assert(preview.visible and is_instance_valid(penguin))
			assert(preview.selected_scene == card.characters[character_index].character_scene)
			assert(penguin.current_weapon != null and penguin.current_weapon.wielder == penguin)
			assert(penguin.body.is_playing())
			assert(not penguin.is_physics_processing())
			assert(not penguin.current_weapon.is_processing())
			assert(not penguin.player_indicator.visible)
			assert(penguin.collision_layer == 0 and penguin.damage_hitbox.collision_layer == 0)
			assert(penguin.player_palette_instance.get_shader_parameter("player_color").is_equal_approx(PlayerManager.get_player_color(slot)))
			assert(preview.viewport.world_2d != get_viewport().world_2d)
			var shadow_position: Vector2 = preview.shadow.position
			preview._process(0.25)
			assert(not preview.stage.position.is_equal_approx(preview.resting_position))
			assert(preview.stage.position.distance_to(preview.resting_position) < 2.0)
			assert(preview.shadow.position.is_equal_approx(shadow_position))
			var rendered_bounds: Rect2 = preview.stage.transform * preview.visual_bounds
			assert(Rect2(Vector2.ZERO, Vector2(preview.viewport.size)).grow(0.1).encloses(rendered_bounds))
		await get_tree().process_frame
		await get_tree().process_frame
		assert(get_tree().get_nodes_in_group("active_penguins").is_empty())
	for dimensions in [Vector2i(1152, 648), Vector2i(1280, 720)]:
		get_tree().root.size = dimensions
		await get_tree().process_frame
		await get_tree().process_frame
		var expected_width: float = selection.player_slots[0].size.x
		for card in selection.player_slots:
			assert(is_equal_approx(card.size.x, expected_width))
			assert(card.navigation.get_global_rect().end.y <= card.card_panel.get_global_rect().end.y)
			assert(card.arena_preview.get_global_rect().position.y >= card.card_panel.get_global_rect().end.y)
			assert(card.arena_preview.get_global_rect().end.y <= selection.get_node("Footer").get_global_rect().position.y)
			assert(not card.arena_preview.has_node("Caption"))
			assert(card.arena_preview.shadow.visible)
	var first: PlayerSelection = selection.player_slots[0]
	var initial_preview = first.arena_preview.character_instance
	first.confirm_character()
	assert(first.arena_preview.character_instance == initial_preview)
	first.cancel_selection()
	assert(first.arena_preview.visible)
	first.cancel_selection()
	assert(not first.arena_preview.visible and first.arena_preview.character_instance == null)
	assert(not first.preview_area.visible)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(is_equal_approx(first.card_panel.size.y, first.size.y))
	selection.activate_player_slot(-1)
	assert(first.arena_preview.visible and first.arena_preview.penguin != null)
	selection.free()
	PlayerManager.clear_players()
	print("PASS: four classes and slot colors, real animated equipped scenes, isolated inactive gameplay, fitted previews, equal card widths, full-height empty cards, compact joined cards, separate card and figure, stable shadow, gentle idle, footer clearance and join/ready/change/leave lifecycle")
	get_tree().quit()
