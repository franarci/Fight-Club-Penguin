extends SceneTree

class MatchHost extends Node:
	var starts := 0
	func start_game() -> void:
		starts += 1


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	var host := MatchHost.new()
	root.add_child(host)
	current_scene = host
	var selector = load("res://src/ui/character_selection/character_select.tscn").instantiate()
	host.add_child(selector)
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	assert(not selector.countdown_overlay.visible)
	assert(selector.countdown.one_shot)

	selector.activate_player_slot(-1)
	selector.player_slots[0].confirm_character()
	assert(selector.countdown_step == -1)
	selector.activate_player_slot(0)
	selector.player_slots[1].confirm_character()
	assert(selector.countdown_step == 0)
	assert(selector.countdown_overlay.number_label.text == "3")
	assert(selector.countdown_overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	await create_timer(0.12).timeout
	assert(selector.countdown_overlay.panel.scale.x > 0.15)
	var remaining: float = selector.countdown.time_left
	selector._on_player_ready_changed()
	assert(selector.countdown.time_left <= remaining)
	selector.player_slots[0].cancel_selection()
	assert(selector.countdown_step == -1 and selector.countdown.is_stopped())
	assert(not selector.countdown_overlay.visible)
	assert(selector.countdown_overlay.pulse == null)

	selector.player_slots[0].confirm_character()
	assert(selector.countdown_step == 0)
	selector.activate_player_slot(1)
	assert(selector.countdown_step == -1)
	selector.player_slots[2].confirm_character()
	assert(selector.countdown_step == 0)
	selector.player_slots[2].cancel_selection()
	selector.player_slots[2].cancel_selection()
	assert(manager.players.size() == 2)
	assert(selector.countdown_step == 0)

	var observed: Array[String] = ["3"]
	selector.countdown.timeout.connect(func():
		if selector.countdown_step >= 0 and selector.countdown_step < 4:
			observed.append(selector.countdown_overlay.number_label.text)
	)
	await create_timer(4.3).timeout
	assert(observed == ["3", "2", "1", "GO!"])
	assert(host.starts == 1)
	assert(not selector.visible)
	selector._on_countdown_timeout()
	selector.finish_character_selection()
	assert(host.starts == 1)
	host.free()
	manager.clear_players()
	print("PASS: countdown display, growth, readiness, cancellation, joining/leaving, restart and single match start")
	quit()
