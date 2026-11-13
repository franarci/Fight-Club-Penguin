extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func joy_event(device: int, button: int) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	return event


func key_event(code: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	return event


func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for device in [0, 1]:
		MultiplayerInput.device_actions[device] = {}
		for action in MultiplayerInput.core_actions:
			var name := StringName("audio_%d_%s" % [device, action])
			InputMap.add_action(name)
			MultiplayerInput.device_actions[device][action] = name
			for original in InputMap.action_get_events(action):
				if original is InputEventJoypadButton or original is InputEventJoypadMotion:
					var copy = original.duplicate()
					copy.device = device
					InputMap.action_add_event(name, copy)
	var home = load("res://src/ui/home/Home.tscn").instantiate()
	add_child(home)
	home.options_button.pressed.emit()
	var options = home.audio_options
	assert(options.visible and options.music_mute.has_focus())
	options.music_slider.value = 35
	var music_bus := AudioServer.get_bus_index(&"Music")
	var fx_bus := AudioServer.get_bus_index(&"FX")
	assert(is_equal_approx(AudioServer.get_bus_volume_linear(music_bus), AudioSettings.reference_levels[&"Music"] * 0.35))
	home._input(key_event(KEY_ENTER))
	assert(AudioServer.is_bus_mute(music_bus))
	assert(not AudioServer.is_bus_mute(fx_bus))
	options.fx_slider.value = 55
	assert(AudioSettings.volumes[&"Music"] == 35 and AudioSettings.volumes[&"FX"] == 55)
	home._input(key_event(KEY_ENTER))
	assert(not AudioServer.is_bus_mute(music_bus) and options.music_slider.value == 35)
	await get_tree().process_frame
	var panel: Control = options.get_node("Dim/Center/Panel")
	assert(Rect2(Vector2.ZERO, Vector2(1152, 648)).encloses(panel.get_global_rect()))
	for control in options._controls():
		assert(panel.get_global_rect().encloses(control.get_global_rect()))
	var checkbox_size: Vector2 = options.fx_mute.get_combined_minimum_size()
	await click(options.fx_mute)
	assert(AudioSettings.muted[&"FX"] and not AudioSettings.muted[&"Music"])
	assert(options.fx_mute.get_combined_minimum_size() == checkbox_size)
	await click(options.fx_mute)
	assert(not AudioSettings.muted[&"FX"])
	await click(options.fx_slider)
	assert(options.fx_slider.value > 0 and options.fx_slider.value < 100)
	options.fx_slider.value = 55
	home._input(key_event(KEY_ESCAPE))
	assert(not options.visible and home.options_button.has_focus())
	home._input(joy_event(0, JOY_BUTTON_A))
	home.options_button.pressed.emit()
	assert(options.owner_device == 0)
	home._input(joy_event(0, JOY_BUTTON_B))
	assert(not options.visible)
	home.free()
	var pause = load("res://src/ui/pause/PauseMenu.tscn").instantiate()
	add_child(pause)
	get_tree().paused = true
	pause.open(0, 0)
	pause.options_button.pressed.emit()
	options = pause.audio_options
	assert(options.visible and options.music_slider.value == 35 and options.fx_slider.value == 55)
	pause._input(key_event(KEY_ENTER))
	assert(not AudioSettings.muted[&"Music"])
	pause._input(joy_event(1, JOY_BUTTON_A))
	assert(not AudioSettings.muted[&"Music"])
	pause._input(joy_event(0, JOY_BUTTON_A))
	assert(AudioSettings.muted[&"Music"])
	options.music_slider.grab_focus()
	Input.action_press(MultiplayerInput.get_action_name(0, "right"))
	options._process(0.0)
	Input.action_release(MultiplayerInput.get_action_name(0, "right"))
	assert(options.music_slider.value == 40)
	pause._input(joy_event(0, JOY_BUTTON_B))
	assert(not options.visible and pause.active and get_tree().paused)
	assert(pause.options_button.has_focus())
	var missing: Array[int] = [1]
	pause.show_recovery(missing, {})
	pause.options_button.pressed.emit()
	pause._input(key_event(KEY_ENTER))
	assert(not AudioSettings.muted[&"Music"])
	pause.dismiss()
	assert(not options.visible)
	get_tree().paused = false
	pause.free()
	for path in ["res://src/entities/prototypes/penguin/penguin_base.tscn", "res://src/entities/prototypes/weapons/ranged/RangedWeapon.tscn", "res://src/entities/prototypes/weapons/melee/MeleeWeapon.tscn"]:
		var state = load(path).get_state()
		for index in range(state.get_node_count()):
			if state.get_node_type(index) != &"AudioStreamPlayer":
				continue
			var routed := false
			for property_index in range(state.get_node_property_count(index)):
				if state.get_node_property_name(index, property_index) == &"bus":
					routed = state.get_node_property_value(index, property_index) == &"FX"
			assert(routed)
	for bus in AudioSettings.BUSES:
		AudioSettings.set_muted(bus, false)
		AudioSettings.set_volume(bus, 100)
	print("PASS: independent Music/FX gain and mute, retained levels, shared Home/pause state, paused controller ownership, recovery input, layout and effect routing")
	get_tree().quit()


func click(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	get_tree().root.push_input(motion)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		get_tree().root.push_input(event)
	await get_tree().process_frame
