extends SceneTree

class TickProbe extends Node:
	var ticks := 0
	func _process(_delta: float) -> void:
		ticks += 1


func _initialize() -> void:
	call_deferred("run_checks")


func key_event(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	return event


func joy_event(device: int, button: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	return event


func settle() -> void:
	await process_frame
	await process_frame
	await process_frame


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	var inputs = root.get_node("MultiplayerInput")
	inputs.device_actions[0] = {}
	for action in inputs.core_actions:
		var name: StringName = "test_" + String(action)
		InputMap.add_action(name)
		inputs.device_actions[0][action] = name
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				var copy = event.duplicate()
				copy.device = 0
				InputMap.action_add_event(name, copy)
	manager.clear_players()
	for slot in range(2):
		manager.join_player(slot - 1, slot)
		var data := CharacterData.new()
		data.key = "Gunner"
		manager.set_character(slot - 1, data)
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main._input(key_event(KEY_ESCAPE))
	assert(not paused)
	main.start_game()
	var probe := TickProbe.new()
	main.add_child(probe)
	await settle()
	assert(probe.ticks > 0)
	main._input(key_event(KEY_ESCAPE))
	assert(paused and main.pause_menu.active)
	assert(main.pause_menu.owner_device == -1)
	var ticks: int = probe.ticks
	await settle()
	assert(probe.ticks == ticks)
	main.pause_menu._input(joy_event(0, JOY_BUTTON_A))
	assert(paused)
	main.pause_menu._input(key_event(KEY_ESCAPE))
	assert(not paused and not main.pause_menu.active)
	await settle()
	assert(probe.ticks > ticks)
	main._input(joy_event(0, JOY_BUTTON_START))
	assert(paused and main.pause_menu.owner_device == 0)
	main.pause_menu._input(key_event(KEY_ESCAPE))
	assert(paused)
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	assert(not main.pause_menu._is_owner_event(mouse))
	assert(main.pause_menu._is_owner_event(joy_event(0, JOY_BUTTON_A)))
	assert(not main.pause_menu._is_owner_event(joy_event(1, JOY_BUTTON_A)))
	main.pause_menu._move_focus(1)
	assert(main.pause_menu.exit_button.has_focus())
	main.pause_menu._input(joy_event(0, JOY_BUTTON_A))
	assert(main.pause_menu.confirmation.visible)
	assert(main.pause_menu.cancel_exit.has_focus())
	main.pause_menu._input(joy_event(0, JOY_BUTTON_A))
	assert(not main.pause_menu.confirmation.visible and paused)
	main.pause_menu._input(joy_event(0, JOY_BUTTON_A))
	assert(main.pause_menu.confirmation.visible)
	main.pause_menu._input(joy_event(0, JOY_BUTTON_B))
	assert(not main.pause_menu.confirmation.visible and paused)
	main.pause_menu._input(joy_event(0, JOY_BUTTON_A))
	main.pause_menu._move_focus(1)
	main.pause_menu._input(joy_event(0, JOY_BUTTON_A))
	await settle()
	assert(not paused and manager.players.is_empty())
	assert(current_scene.name == "Home")
	for slot in range(2):
		manager.join_player(slot - 1, slot)
		var data := CharacterData.new()
		data.key = "Gunner"
		manager.set_character(slot - 1, data)
	var next_main = load("res://Main.tscn").instantiate()
	current_scene.free()
	root.add_child(next_main)
	current_scene = next_main
	next_main.start_game()
	next_main._input(joy_event(0, JOY_BUTTON_START))
	assert(paused and next_main.pause_menu.active)
	manager.set_lives(0, 0)
	next_main._check_round_result()
	assert(next_main.round_finished and next_main.round_result.active)
	assert(not next_main.pause_menu.active and not next_main.pause_menu.visible)
	next_main.round_result._on_replay_pressed()
	await settle()
	assert(not paused and current_scene.round_started)
	assert(not current_scene.pause_menu.active)
	current_scene.free()
	manager.clear_players()
	print("PASS: pause context, simulation freeze/resume, exclusive device input, confirmation/cancel and return to Home")
	quit()
