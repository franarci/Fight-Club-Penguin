extends SceneTree

const Hints = preload("res://src/ui/shared/control_hints.gd")


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var cases := {
		"Sony DualShock 4": "PlayStation",
		"PS4 Controller": "PlayStation",
		"DualSense Wireless Controller": "PlayStation",
		"Wireless Controller (STANDARD GAMEPAD Vendor: 054c Product: 09cc)": "PlayStation",
		"Wireless Controller (STANDARD GAMEPAD Vendor: 054C Product: 0CE6)": "PlayStation",
		"054c-05c4-Wireless Controller": "PlayStation",
		"54c-9cc-Wireless Controller": "PlayStation",
		"54c-ce6-Wireless Controller": "PlayStation",
		"Xbox Wireless Controller (STANDARD GAMEPAD Vendor: 045e Product: 0b13)": "Xbox / Gamepad",
		"045e-0b13-Xbox Wireless Controller": "Xbox / Gamepad",
		"Generic Gamepad (Vendor: 1234 Product: 054c)": "Xbox / Gamepad",
		"Generic Gamepad (Vendor: 054c0 Product: 1234)": "Xbox / Gamepad",
		"Wireless Controller": "Xbox / Gamepad",
		"": "Xbox / Gamepad"
	}
	for device_name in cases:
		var family: String = Hints.family_from_name(device_name)
		assert(family == cases[device_name], device_name)
		var icon: String = Hints.joypad_icon(family, JOY_BUTTON_A, Hints.is_ps5_name(device_name))
		assert(ResourceLoader.exists(icon))
		assert(icon.ends_with("playstation_button_color_cross.png") if family == "PlayStation" else icon.ends_with("xbox_button_a.png"))
	for device_name in ["DualSense", "PS5 Controller", "Wireless Controller (Vendor: 054c Product: 0ce6)", "54c-df2-Wireless Controller", "054c-0e5f-Access Controller"]:
		assert(Hints.is_ps5_name(device_name), device_name)
		assert(Hints.joypad_icon("PlayStation", JOY_BUTTON_START, Hints.is_ps5_name(device_name)).ends_with("playstation5_button_options.png"))
	for device_name in ["DualShock 4", "Wireless Controller (Vendor: 054c Product: 09cc)", "045e-0ce6-Xbox", "Wireless Controller"]:
		assert(not Hints.is_ps5_name(device_name), device_name)
	assert(Hints.device_family(-1) == "Keyboard")
	assert(Hints.confirmation_action(-1) == &"player_join")
	assert(Hints.confirmation_action(0) == &"selection_accept")
	print("PASS: desktop and web controller identifiers, Sony vendor detection, PS4/PS5 icons, Xbox and generic fallback")
	quit()
