extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	root.size = Vector2i(1152, 648)
	var manager = root.get_node("PlayerManager")
	var music = root.get_node("Music")
	var inputs = root.get_node("MultiplayerInput")
	inputs.device_actions[0] = {}
	for action in inputs.core_actions:
		inputs.device_actions[0][action] = action
	manager.clear_players()
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	assert(music.active_player == music.menu_player)
	var selector = main.character_select
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	selector.activate_player_slot(-1)
	selector.activate_player_slot(0)
	selector.player_slots[1].next()
	for slot in [selector.player_slots[0], selector.player_slots[1]]:
		slot.confirm_character()
	await process_frame
	assert(selector.ready_dialog.visible)
	selector.finish_character_selection()
	assert(paused and main.pre_match.active)
	assert(music.active_player == music.menu_player)
	main.pre_match.advance()
	main.pre_match.advance()
	for i in range(4):
		main.pre_match._on_countdown_timeout()
	assert(not paused and not main.pre_match.active)
	assert(music.active_player == music.combat_player)
	var gunner = main.players.get_child(0).get_child(0)
	var demolisher = main.players.get_child(1).get_child(0)
	assert(gunner.current_weapon.get_script().get_global_name() == "RangedWeapon")
	assert(demolisher.current_weapon.get_script().get_global_name() == "MeleeWeapon")
	assert(main.get_node("SharedCamera").players == main.players)
	assert(gunner.ice_boundary != null and demolisher.ice_boundary != null)
	for i in range(3):
		gunner.protection_left = 0
		gunner.receive_damage(gunner.max_health + 1, demolisher)
		if i < 2:
			gunner._on_respawn_timer_timeout()
	await process_frame
	await process_frame
	assert(main.round_finished and main.round_result.active and paused)
	assert(main.round_result.title.text == "Player 2 wins!")
	main.round_result._on_replay_pressed()
	await process_frame
	await process_frame
	await process_frame
	main = current_scene
	assert(main.round_started and paused and main.players.get_child_count() == 2)
	assert(main.pre_match.countdown_step == 0 and not main.pre_match.background.visible)
	assert(music.active_player == music.menu_player)
	for i in range(4):
		main.pre_match._on_countdown_timeout()
	assert(not paused)
	assert(music.active_player == music.combat_player)
	assert(manager.get_lives(0) == 3 and manager.get_lives(1) == 3)
	assert(main.players.get_child(1).get_child(0).current_weapon.get_script().get_global_name() == "MeleeWeapon")
	main.pause_menu.open(-1, 0)
	paused = true
	main._return_to_menu()
	await process_frame
	await process_frame
	assert(current_scene.name == "Home" and manager.players.is_empty() and not paused)
	assert(music.active_player == music.menu_player)
	current_scene.free()
	print("PASS: integrated ready/tutorial/countdown, rifle and hammer, shared camera, polygon bounds, elimination, winner, replay and return to Home")
	quit()
