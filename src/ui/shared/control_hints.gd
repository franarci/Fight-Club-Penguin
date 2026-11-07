extends RefCounted


static func device_family(device: int) -> String:
	if device < 0:
		return "Keyboard"
	if Input.get_connected_joypads().has(device):
		return family_from_name(device_name(device))
	return "Xbox / Gamepad"


static func device_name(device: int) -> String:
	if OS.has_feature("web"):
		var navigator = JavaScriptBridge.get_interface("navigator")
		if navigator != null:
			var pads = navigator.getGamepads()
			if pads != null and device >= 0 and device < int(pads.length):
				var pad = pads[device]
				if pad != null and bool(pad.connected):
					return str(pad.id)
	return Input.get_joy_name(device)


static func family_from_name(device_name: String) -> String:
	var name := device_name.strip_edges().to_lower()
	if name.trim_suffix(" (standard gamepad)").strip_edges() == "wireless controller":
		return "PlayStation"
	for keyword in ["sony", "playstation", "dualshock", "dualsense", "ps4", "ps5"]:
		if keyword in name:
			return "PlayStation"
	var vendor_pattern := RegEx.new()
	vendor_pattern.compile(r"(?:\bvendor:\s*0*54c\b|^0*54c-[0-9a-f]+-)")
	if vendor_pattern.search(name) != null:
		return "PlayStation"
	return "Xbox / Gamepad"


static func is_ps5_name(device_name: String) -> bool:
	var name := device_name.to_lower()
	if "dualsense" in name or "ps5" in name:
		return true
	var product_pattern := RegEx.new()
	product_pattern.compile(r"(?:\bvendor:\s*0*54c\s+product:\s*0*(?:ce6|df2|e5f)\b|^0*54c-0*(?:ce6|df2|e5f)-)")
	return product_pattern.search(name) != null


static func confirmation_action(device: int) -> StringName:
	return &"player_join" if device < 0 else &"selection_accept"


static func binding(device: int, action: StringName) -> String:
	if action == &"menu_confirm":
		action = confirmation_action(device)
	var labels := PackedStringArray()
	for event in InputMap.action_get_events(action):
		var label := ""
		if device < 0 and event is InputEventKey:
			label = OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
		elif device >= 0 and event is InputEventJoypadButton:
			var buttons: Dictionary = {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_START: "Start"}
			if device_family(device) == "PlayStation":
				buttons = {JOY_BUTTON_A: "×", JOY_BUTTON_B: "○", JOY_BUTTON_X: "□", JOY_BUTTON_Y: "△", JOY_BUTTON_START: "Options"}
			label = buttons.get(event.button_index, "Button %d" % (event.button_index + 1))
		if not label.is_empty() and not labels.has(label):
			labels.append(label)
	return " / ".join(labels)


static func movement(device: int) -> String:
	if device < 0:
		var keys := PackedStringArray()
		for action in [&"up", &"left", &"down", &"right"]:
			keys.append(binding(device, action))
		return " / ".join(keys)
	return "Left stick / D-pad"


static func joypad_icon(family: String, button: int, ps5: bool = false) -> String:
	var names: Dictionary = {
		JOY_BUTTON_A: "xbox_button_a", JOY_BUTTON_B: "xbox_button_b",
		JOY_BUTTON_X: "xbox_button_x", JOY_BUTTON_Y: "xbox_button_y",
		JOY_BUTTON_START: "xbox_button_menu"
	}
	if family == "PlayStation":
		names = {
			JOY_BUTTON_A: "playstation_button_color_cross", JOY_BUTTON_B: "playstation_button_color_circle",
			JOY_BUTTON_X: "playstation_button_color_square", JOY_BUTTON_Y: "playstation_button_color_triangle",
			JOY_BUTTON_START: "playstation5_button_options" if ps5 else "playstation4_button_options"
		}
	return "res://assets/ui/input_prompts/%s.png" % names[button] if names.has(button) else ""


static func icon_paths(device: int, action: StringName) -> PackedStringArray:
	if action == &"menu_confirm":
		action = confirmation_action(device)
	var paths := PackedStringArray()
	for event in InputMap.action_get_events(action):
		var path := ""
		if device < 0 and event is InputEventKey:
			var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			path = "res://assets/ui/input_prompts/keyboard_%s.png" % OS.get_keycode_string(key).to_lower()
		elif device >= 0 and event is InputEventJoypadButton:
			var ps5 := false
			if Input.get_connected_joypads().has(device):
				ps5 = is_ps5_name(device_name(device))
			path = joypad_icon(device_family(device), event.button_index, ps5)
		if not path.is_empty() and ResourceLoader.exists(path) and not paths.has(path):
			paths.append(path)
	return paths


static func movement_icons(device: int) -> PackedStringArray:
	var paths := PackedStringArray()
	if device < 0:
		for action in [&"up", &"left", &"down", &"right"]:
			paths.append_array(icon_paths(device, action))
	else:
		var prefix := "playstation" if device_family(device) == "PlayStation" else "xbox"
		paths.append("res://assets/ui/input_prompts/%s_stick_l.png" % prefix)
		paths.append("res://assets/ui/input_prompts/%s_dpad.png" % prefix)
	return paths
