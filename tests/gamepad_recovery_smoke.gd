extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func joy_event(device: int, button: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	return event


func key_event(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	return event


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	var inputs = root.get_node("MultiplayerInput")
	for device in range(5):
		inputs.device_actions[device] = {}
		for action in inputs.core_actions:
			var name: StringName = "recovery_%d_%s" % [device, action]
			InputMap.add_action(name)
			inputs.device_actions[device][action] = name
			for event in InputMap.action_get_events(action):
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					var copy = event.duplicate()
					copy.device = device
					InputMap.action_add_event(name, copy)
	manager.clear_players()
	for slot in range(2):
		manager.join_player(slot, slot)
		var data := CharacterData.new()
		data.key = "Gunner"
		data.character_scene = load("res://src/entities/prototypes/characters/%s.tscn" % data.key)
		manager.set_character(slot, data)
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.start_game()
	await process_frame
	var recovery = main.gamepad_recovery
	var menu = main.pause_menu
	var first = main.players.get_child(0).get_child(0)
	first.set_health(37.0)
	manager.set_lives(0, 2)
	var position_before: Vector2 = first.global_position
	var hp_before: float = first.current_health
	var lives_before: int = manager.get_lives(0)
	var model_a := {"guid": "model-a", "name": "Controller A", "serial": ""}
	var model_b := {"guid": "model-b", "name": "Controller B", "serial": ""}
	recovery.begin_round({0: model_a, 1: model_b})
	main._input(joy_event(0, JOY_BUTTON_START))
	assert(paused and not menu.shared_control)
	recovery.handle_connection(0, false)
	assert(paused and menu.shared_control and menu.continue_button.disabled)
	assert(manager.get_lives(0) == lives_before)
	menu._input(key_event(KEY_ESCAPE))
	assert(paused)
	menu.exit_button.grab_focus()
	menu._input(joy_event(1, JOY_BUTTON_A))
	assert(menu.confirmation.visible)
	recovery.handle_connection(2, true, model_a)
	assert(not menu.confirmation.visible)
	assert(first.device == 2 and first.current_weapon.device == 2)
	assert(manager.get_player_by_device(2)["slot"] == 0)
	assert(first.global_position == position_before and first.current_health == hp_before)
	assert(paused and not menu.continue_button.disabled)
	menu._input(key_event(KEY_ESCAPE))
	assert(paused)
	menu._input(key_event(KEY_ENTER))
	assert(not paused and not menu.active)
	recovery.begin_round({2: model_a, 1: model_a})
	recovery.handle_connection(2, false)
	recovery.handle_connection(1, false)
	recovery.handle_connection(3, true, model_a)
	assert(recovery.missing.size() == 2 and menu.choice_buttons.size() == 2)
	menu.choice_buttons[0].grab_focus()
	menu._input(key_event(KEY_ENTER))
	assert(recovery.missing.size() == 2 and menu.exit_button.has_focus())
	recovery.handle_connection(4, true, model_a)
	assert(recovery.missing.size() == 2)
	menu.choice_buttons[1].grab_focus()
	menu._input(joy_event(3, JOY_BUTTON_A))
	assert(not recovery.has_missing_players())
	assert(manager.get_player_by_device(3)["slot"] == 1)
	assert(manager.get_player_by_device(4)["slot"] == 0)
	assert(paused and not menu.continue_button.disabled)
	menu._input(joy_event(3, JOY_BUTTON_A))
	assert(not paused)
	recovery.begin_round({4: model_a, 3: model_b})
	recovery.handle_connection(4, false)
	recovery.handle_connection(2, true, model_b)
	assert(recovery.has_missing_players())
	assert(menu.choice_buttons.size() == 1)
	menu._input(joy_event(2, JOY_BUTTON_A))
	assert(not recovery.has_missing_players() and first.device == 2 and paused)
	menu._input(key_event(KEY_ENTER))
	assert(not paused)
	var serial_a := {"guid": "same-model", "name": "Same controller", "serial": "a"}
	var serial_b := {"guid": "same-model", "name": "Same controller", "serial": "b"}
	recovery.begin_round({2: serial_a, 3: serial_b})
	recovery.handle_connection(2, false)
	recovery.handle_connection(3, false)
	recovery.handle_connection(4, true, serial_b)
	assert(recovery.missing.size() == 1 and manager.get_player_by_device(4)["slot"] == 1)
	recovery.handle_connection(0, true, serial_a)
	assert(not recovery.has_missing_players() and first.device == 0)
	assert(first.current_health == 37.0 and manager.get_lives(0) == 2)
	menu._input(key_event(KEY_ENTER))
	assert(not paused)
	manager.set_lives(0, 0)
	recovery.handle_connection(0, false)
	assert(not paused and not recovery.has_missing_players())
	recovery.handle_connection(4, false)
	assert(paused)
	menu.exit_button.grab_focus()
	menu._input(key_event(KEY_ENTER))
	assert(menu.confirmation.visible)
	menu.confirm_exit.grab_focus()
	menu._input(joy_event(0, JOY_BUTTON_A))
	await process_frame
	await process_frame
	assert(not paused and manager.players.is_empty() and current_scene.name == "Home")
	current_scene.free()
	print("PASS: unique and ambiguous recovery, shared pause, reserved state, weapon rebinding, manual resume and menu exit")
	quit()
