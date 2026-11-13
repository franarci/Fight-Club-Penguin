extends Node

var clicks := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	var action := ActionButton.new()
	add_child(action)
	action.configure("Continue", [-1], ["menu_confirm"])
	action.position = Vector2(20, 20)
	action.size = action.get_combined_minimum_size()
	action.pressed.connect(func(): clicks += 1)
	await settle()
	await click(action)
	assert(clicks == 1)
	action.disabled = true
	await click(action)
	assert(clicks == 1)
	action.disabled = false
	action.grab_focus()
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ENTER
		event.physical_keycode = KEY_ENTER
		event.pressed = pressed
		get_tree().root.push_input(event)
	assert(clicks == 2)
	assert(action.text.is_empty() and action.accessibility_name == "Continue")
	assert(action.get_child_count() == 1 and action.prompt.get_child_count() == 2)
	assert(not action.flat)
	assert_action_layout(action)
	action.free()

	PlayerManager.clear_players()
	MultiplayerInput.device_actions[0] = {}
	for core_action in MultiplayerInput.core_actions:
		MultiplayerInput.device_actions[0][core_action] = core_action
	var main = load("res://Main.tscn").instantiate()
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	var selector = main.character_select
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	selector.activate_player_slot(-1)
	selector.activate_player_slot(0)
	for slot in [selector.player_slots[0], selector.player_slots[1]]:
		slot.confirm_character()
	await settle()
	assert(selector.ready_dialog.visible)
	assert(not selector.has_node("ReadyDialog/Center/Panel/Margin/Content/Buttons"))
	assert(selector.ready_prompts.get_child_count() == 2)
	assert(selector.ready_accept.caption == "Let's play" and selector.ready_cancel.caption == "Keep choosing")
	assert(selector.ready_accept is ActionButton and selector.ready_cancel is ActionButton)
	assert_action_layout(selector.ready_accept)
	assert_action_layout(selector.ready_cancel)
	assert(selector.ready_accept.get_global_rect().end.x + 24.0 <= selector.ready_cancel.get_global_rect().position.x + 0.01)
	var panel: Control = selector.get_node("ReadyDialog/Center/Panel")
	assert(Rect2(Vector2.ZERO, Vector2(1152, 648)).encloses(panel.get_global_rect()))
	await click(selector.ready_cancel)
	assert(not selector.ready_dialog.visible and not main.round_started)
	assert(selector.are_all_players_ready())
	var reopen := InputEventKey.new()
	reopen.keycode = KEY_ENTER
	reopen.physical_keycode = KEY_ENTER
	reopen.pressed = true
	selector._input(reopen)
	await settle()
	await click(selector.ready_accept)
	assert(main.round_started and get_tree().paused and main.pre_match.active)
	var tutorial = main.pre_match
	assert(not tutorial.has_node("Background/Center/Panel/Margin/Content/Hint"))
	assert(tutorial.next_button.caption == "Next" and not tutorial.back_button.visible)
	await settle()
	await click(tutorial.next_button)
	assert(tutorial.page == 1 and tutorial.back_button.visible)
	assert_action_layout(tutorial.next_button)
	assert_action_layout(tutorial.back_button)
	assert(tutorial.back_button.get_global_rect().end.x + 16.0 <= tutorial.next_button.get_global_rect().position.x + 0.01)
	await click(tutorial.back_button)
	assert(tutorial.page == 0)
	await click(tutorial.next_button)
	await click(tutorial.next_button)
	assert(tutorial.countdown_step == 0 and not tutorial.background.visible)
	get_tree().paused = false
	get_tree().current_scene = null
	main.free()
	PlayerManager.clear_players()
	print("PASS: real mouse/keyboard activation, disabled state, visible backgrounds, nonoverlapping content bounds, ready cancel/start and tutorial navigation")
	get_tree().quit()


func click(button: Button) -> void:
	await settle()
	var point := button.get_global_rect().get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		get_tree().root.push_input(event)
	await settle()


func settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func assert_action_layout(button: ActionButton) -> void:
	var required := button.prompt.get_combined_minimum_size() + button.content_padding * 2.0
	assert(button.size.x >= required.x and button.size.y >= required.y)
	assert(button.get_global_rect().encloses(button.prompt.get_global_rect()))
