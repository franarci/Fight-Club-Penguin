extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	PlayerManager.clear_players()
	assert(PlayerManager.join_player(-1, 0))
	assert(PlayerManager.join_player(0, 1))
	MultiplayerInput.device_actions[0] = {}
	for action in MultiplayerInput.core_actions:
		var mapped: StringName = "navigation_0_%s" % action
		InputMap.add_action(mapped)
		MultiplayerInput.device_actions[0][action] = mapped
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				var copy = event.duplicate()
				copy.device = 0
				InputMap.action_add_event(mapped, copy)
	var tutorial = load("res://src/ui/tutorial/PreMatch.tscn").instantiate()
	add_child(tutorial)
	get_tree().paused = true
	tutorial.open()
	assert("5 minutes" in tutorial.objective.text)
	assert(not tutorial.has_node("Background/Center/Panel/Margin/Content/WeaponGuides"))
	assert(tutorial.page == 0 and tutorial.objective.visible and not tutorial.back_button.visible)
	assert(not tutorial.charge_tutorial.visible)
	tutorial.go_back()
	assert(tutorial.page == 0)
	tutorial.advance()
	assert(tutorial.page == 1 and tutorial.controls.visible and tutorial.back_button.visible)
	assert(not tutorial.charge_tutorial.visible)
	assert(tutorial.next_button.caption == "Next" and tutorial.back_button.caption == "Back")
	for column in tutorial.controls.get_children():
		var attack_prompt: HBoxContainer = column.get_child(3)
		assert(attack_prompt.get_child(0).text == "Attack")
		assert(attack_prompt.get_child(1) is TextureRect)
	await settle()
	var panel: Control = tutorial.get_node("Background/Center/Panel")
	assert(Rect2(Vector2.ZERO, Vector2(1152, 648)).encloses(panel.get_global_rect()))
	assert(tutorial.back_button.get_global_rect().end.x <= tutorial.next_button.get_global_rect().position.x)
	tutorial.back_button.pressed.emit()
	assert(tutorial.page == 0 and not tutorial.back_button.visible)
	assert(not tutorial.charge_tutorial.visible)
	tutorial.advance()
	var cancel := InputEventKey.new()
	cancel.physical_keycode = KEY_ESCAPE
	cancel.pressed = true
	tutorial._input(cancel)
	assert(tutorial.page == 0)
	tutorial.advance()
	var circle := InputEventJoypadButton.new()
	circle.device = 0
	circle.button_index = JOY_BUTTON_B
	circle.pressed = true
	tutorial._input(circle)
	assert(tutorial.page == 0)
	tutorial.advance()
	tutorial.suspend()
	tutorial.go_back()
	assert(tutorial.page == 1)
	tutorial.resume()
	assert(tutorial.page == 1 and tutorial.back_button.visible)
	tutorial.advance()
	assert(tutorial.page == 2 and tutorial.charge_tutorial.visible and not tutorial.controls.visible)
	assert(tutorial.next_button.caption == "Start countdown")
	assert(tutorial.demonstrations.get_child_count() == 2)
	await settle()
	assert(Rect2(Vector2.ZERO, Vector2(1152, 648)).encloses(panel.get_global_rect()))
	assert(tutorial.charge_tutorial.get_global_rect().end.y <= tutorial.back_button.get_global_rect().position.y)
	for demo in tutorial.demonstrations.get_children():
		assert(demo.running and demo.weapon != null)
		assert(demo.button_content.get_child(0).get_child_count() >= 2)
		assert(demo.viewport.world_2d != get_viewport().world_2d)
	var saw_harpoon := false
	var saw_shockwave := false
	for tick in range(240):
		await get_tree().physics_frame
		var hunter = tutorial.demonstrations.get_child(0)
		var demolisher = tutorial.demonstrations.get_child(1)
		if is_instance_valid(hunter.weapon) and is_instance_valid(hunter.weapon.harpoon_projectile):
			saw_harpoon = true
		if is_instance_valid(demolisher.character_instance) and demolisher.character_instance.get_child_count() > 1:
			saw_shockwave = true
	assert(saw_harpoon and saw_shockwave)
	assert(get_tree().get_nodes_in_group("active_penguins").is_empty())
	tutorial.suspend()
	for demo in tutorial.demonstrations.get_children():
		assert(not demo.running and demo.character_instance == null)
	tutorial.resume()
	assert(tutorial.page == 2 and tutorial.charge_tutorial.visible)
	tutorial.go_back()
	assert(tutorial.page == 1 and not tutorial.charge_tutorial.visible)
	for demo in tutorial.demonstrations.get_children():
		assert(not demo.running and demo.character_instance == null)
	tutorial.advance()
	tutorial.advance()
	assert(tutorial.countdown_step == 0 and not tutorial.background.visible)
	tutorial.go_back()
	assert(tutorial.countdown_step == 0 and tutorial.page == 2)
	for step in range(4):
		tutorial._on_countdown_timeout()
	assert(not tutorial.active)
	tutorial.open(true)
	assert(tutorial.countdown_step == 0 and not tutorial.background.visible)
	get_tree().paused = false
	tutorial.free()
	PlayerManager.clear_players()
	print("PASS: three tutorial pages, real harpoon and shockwave demonstrations while paused, isolated worlds, animated hold/release, five-minute rules, Attack icons, mouse/keyboard/gamepad back, pause/recovery and countdown guards")
	get_tree().quit()


func settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
