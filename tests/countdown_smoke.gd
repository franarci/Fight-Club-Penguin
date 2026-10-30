extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func joy_event(device: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = JOY_BUTTON_A
	event.pressed = true
	return event


func key_event() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_ENTER
	event.physical_keycode = KEY_ENTER
	event.pressed = true
	return event


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	var inputs = root.get_node("MultiplayerInput")
	for device in range(2):
		inputs.device_actions[device] = {}
		for action in inputs.core_actions:
			var name: StringName = "tutorial_%d_%s" % [device, action]
			InputMap.add_action(name)
			inputs.device_actions[device][action] = name
			for event in InputMap.action_get_events(action):
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					var copy = event.duplicate()
					copy.device = device
					InputMap.action_add_event(name, copy)
	manager.clear_players()
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var selector = main.character_select
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	assert(not selector.has_node("Footer/StartButton"))
	selector.finish_character_selection()
	assert(not main.round_started)
	selector.activate_player_slot(-1)
	selector.player_slots[0].confirm_character()
	await process_frame
	assert(not selector.ready_dialog.visible)
	selector.activate_player_slot(0)
	selector.player_slots[1].confirm_character()
	await process_frame
	assert(selector.ready_dialog.visible and not main.round_started)
	selector._process(0.0)
	selector._dismiss_ready_dialog()
	assert(not selector.ready_dialog.visible and selector.are_all_players_ready())
	selector._process(0.0)
	selector.player_slots[0].cancel_selection()
	assert(not selector.are_all_players_ready())
	selector.player_slots[0].confirm_character()
	await process_frame
	assert(selector.ready_dialog.visible)
	selector._process(0.0)
	selector._input(key_event())
	var tutorial = main.pre_match
	assert(main.round_started and tutorial.active and paused)
	assert(tutorial.page == 0 and tutorial.countdown_step == -1)
	assert(tutorial.hint.get_child_count() == 1)
	assert(main.players.get_child_count() == 2)
	var position_before: Vector2 = main.players.get_child(0).get_child(0).global_position
	await create_timer(0.12).timeout
	assert(main.players.get_child(0).get_child(0).global_position == position_before)
	tutorial._input(joy_event(1))
	assert(tutorial.page == 0)
	tutorial._input(joy_event(0))
	assert(tutorial.page == 1)
	assert(tutorial.controls.get_child_count() == 2)
	tutorial._input(key_event())
	assert(tutorial.countdown_step == 0)
	assert(tutorial.countdown_overlay.number_label.text == "3")
	tutorial._input(key_event())
	assert(tutorial.countdown_step == 0)
	await create_timer(0.12).timeout
	assert(tutorial.countdown_overlay.panel.scale.x > 0.15)
	main.gamepad_recovery.handle_connection(0, false)
	assert(tutorial.suspended and not tutorial.visible and paused)
	assert(main.pause_menu.active and main.pause_menu.continue_button.disabled)
	main.gamepad_recovery.handle_connection(0, true, {})
	main.gamepad_recovery.choose_slot(0, 1)
	assert(not main.pause_menu.continue_button.disabled)
	main.pause_menu.continue_button.pressed.emit()
	assert(not tutorial.suspended and tutorial.visible and paused)
	assert(tutorial.countdown_step == 0)
	var observed: Array[String] = ["3"]
	tutorial.countdown.timeout.connect(func():
		if tutorial.countdown_step >= 0:
			observed.append(tutorial.countdown_overlay.number_label.text)
	)
	await create_timer(4.3).timeout
	assert(observed == ["3", "2", "1", "GO!"])
	assert(not tutorial.active and not paused)
	assert(main.players.get_child_count() == 2)
	tutorial._on_countdown_timeout()
	assert(not paused)
	main.free()
	manager.clear_players()
	print("PASS: ready confirmation, cancellation, contextual icons, shared tutorial, frozen arena, countdown and reconnection")
	quit()
