extends SceneTree

const ControlHints = preload("res://src/ui/shared/control_hints.gd")
const ControlPrompt = preload("res://src/ui/shared/control_prompt.gd")


func _initialize() -> void:
	call_deferred("run_checks")


func key_event(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	return event


func run_checks() -> void:
	root.size = Vector2i(1152, 648)
	assert(ControlHints.confirmation_action(-1) == &"player_join")
	assert(ControlHints.confirmation_action(0) == &"selection_accept")
	assert(ControlHints.icon_paths(-1, "menu_confirm") == PackedStringArray(["res://assets/ui/input_prompts/keyboard_enter.png"]))
	assert(ControlHints.icon_paths(0, "menu_confirm") == PackedStringArray(["res://assets/ui/input_prompts/xbox_button_a.png"]))
	var manager = root.get_node("PlayerManager")
	var inputs = root.get_node("MultiplayerInput")
	for device in range(4):
		inputs.device_actions[device] = {}
		for action in inputs.core_actions:
			var name: StringName = "selector_%d_%s" % [device, action]
			InputMap.add_action(name)
			inputs.device_actions[device][action] = name
			for event in InputMap.action_get_events(action):
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					var copy = event.duplicate()
					copy.device = device
					InputMap.action_add_event(name, copy)
	for family in ["PlayStation", "Xbox / Gamepad"]:
		for button in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_START]:
			assert(ResourceLoader.exists(ControlHints.joypad_icon(family, button)))
	var prompt := ControlPrompt.new()
	prompt.configure("Select character", [-1, 0, 1], ["selection_accept"])
	var icons := 0
	for child in prompt.get_children():
		if child is TextureRect:
			icons += 1
	assert(icons == 2)
	prompt.free()
	manager.clear_players()
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var selector = main.character_select
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	for device in [-1, 0, 1, 2]:
		selector.activate_player_slot(device)
	await process_frame
	await process_frame
	var footer: PanelContainer = selector.get_node("Footer")
	assert(footer.get_theme_stylebox("panel").bg_color == Color.BLACK)
	assert(footer.get_global_rect().end.y <= root.size.y)
	assert(selector.footer_actions.get_combined_minimum_size().x <= root.size.x - 32)
	var cards: Rect2 = selector.players_container.get_global_rect()
	assert(cards.position.y >= 40 and cards.end.y < footer.get_global_rect().position.y)
	for slot in selector.player_slots:
		assert(slot.size.x == 220 and slot.size.y == 500)
	for i in [1, 2, 3]:
		selector.player_slots[i].confirm_character()
	Input.action_press("selection_accept")
	selector.player_slots[0].confirm_character()
	await process_frame
	assert(selector.ready_dialog.visible)
	selector._process(0.0)
	assert(not selector.dialog_armed)
	selector._input(key_event(KEY_SPACE))
	assert(not main.round_started)
	Input.action_release("selection_accept")
	selector._process(0.0)
	assert(selector.dialog_armed)
	selector._input(key_event(KEY_SPACE))
	assert(selector.ready_dialog.visible and not main.round_started)
	var start := InputEventJoypadButton.new()
	start.device = 0
	start.button_index = JOY_BUTTON_START
	start.pressed = true
	selector._input(start)
	assert(selector.ready_dialog.visible and not main.round_started)
	var panel: Control = selector.get_node("ReadyDialog/Center/Panel")
	await process_frame
	assert(panel.get_global_rect().position.x >= 0 and panel.get_global_rect().end.x <= root.size.x)
	Input.action_press("selection_cancel")
	selector._input(key_event(KEY_ESCAPE))
	assert(not selector.ready_dialog.visible and selector.are_all_players_ready())
	selector._process(0.0)
	assert(selector.waiting_for_release)
	assert(not selector.player_slots[0].is_processing())
	Input.action_release("selection_cancel")
	selector._process(0.0)
	assert(not selector.waiting_for_release and selector.player_slots[0].is_ready)
	selector._input(key_event(KEY_ENTER))
	assert(selector.ready_dialog.visible and not main.round_started)
	selector._on_joy_connection_changed(0, false)
	selector._on_joy_connection_changed(1, false)
	selector._on_joy_connection_changed(2, false)
	await process_frame
	assert(not selector.ready_dialog.visible and not main.round_started)
	assert(manager.players.size() == 1)
	main.free()
	manager.clear_players()
	print("PASS: centered fixed-width cards, one-row black footer, PNG prompts, modal input release, cancel/reopen and disconnect")
	quit()
