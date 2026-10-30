extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func settle() -> void:
	await process_frame
	await process_frame
	await process_frame


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	var inputs = root.get_node("MultiplayerInput")
	inputs.device_actions[0] = {}
	for action in inputs.core_actions:
		inputs.device_actions[0][action] = action
	manager.clear_players()
	for slot in range(2):
		assert(manager.join_player(slot - 1, slot))
		var data := CharacterData.new()
		data.key = "Gunner"
		manager.set_character(slot - 1, data)
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.start_game()
	assert(not main.round_result.visible)
	var target = main.players.get_child(0).get_child(0)
	target.respawn_delay = 0.01
	target.global_position = Vector2(-1000, -1000)
	target.check_arena_bounds()
	target.check_arena_bounds()
	assert(manager.get_lives(0) == 2)
	assert(not main.round_finished)
	await create_timer(0.06).timeout
	assert(not target.is_dead)
	assert(target.current_health == target.max_health)
	assert(target.global_position.is_equal_approx(target.respawn_position))
	assert(target.protection_left > 0)
	var health: float = target.current_health
	target.receive_damage(10000)
	assert(target.current_health == health)
	target.protection_left = 0
	target.receive_damage(10)
	assert(target.current_health == health - 10)
	assert(manager.get_lives(0) == 2)
	manager.set_lives(0, 1)
	target.receive_damage(10000)
	await settle()
	assert(main.round_finished and paused)
	assert(main.round_result.title.text == "Player 2 wins!")
	assert(target.is_eliminated)
	assert(main.round_result.replay_button.has_focus())
	var stale := Node.new()
	stale.name = "PreviousRoundObject"
	main.add_child(stale)
	var previous_id: int = main.get_instance_id()
	main.round_result._on_replay_pressed()
	await settle()
	main = current_scene
	assert(main.get_instance_id() != previous_id)
	assert(paused and main.round_started and not main.round_finished)
	assert(main.pre_match.active and main.pre_match.countdown_step == 0)
	assert(main.pre_match.countdown_overlay.number_label.text == "3")
	assert(not main.pre_match.background.visible)
	assert(not main.has_node("PreviousRoundObject"))
	assert(manager.players.size() == 2)
	for character in main.players.get_children():
		var penguin = character.get_child(0)
		assert(manager.get_lives(penguin.player_index) == 3)
		assert(penguin.current_health == penguin.max_health)
		assert(not penguin.is_dead and not penguin.is_being_pushed)
		assert(penguin.velocity == Vector2.ZERO)
		assert(penguin.global_position.is_equal_approx(penguin.respawn_position))
	var observed: Array[String] = ["3"]
	main.pre_match.countdown.timeout.connect(func():
		if main.pre_match.countdown_step >= 0:
			observed.append(main.pre_match.countdown_overlay.number_label.text)
	)
	await create_timer(0.12).timeout
	assert(paused)
	for character in main.players.get_children():
		var penguin = character.get_child(0)
		assert(penguin.global_position.is_equal_approx(penguin.respawn_position))
	await create_timer(4.2).timeout
	assert(observed == ["3", "2", "1", "GO!"])
	assert(not paused and not main.pre_match.active)
	for character in main.players.get_children():
		var penguin = character.get_child(0)
		manager.set_lives(penguin.player_index, 1)
		penguin.lose_life()
	await settle()
	assert(main.round_result.title.text == "Draw!")
	assert(paused)
	main._check_round_result()
	assert(main.round_result.title.text == "Draw!")
	main.round_result._on_menu_pressed()
	await settle()
	assert(not paused)
	assert(manager.players.is_empty() and not manager.replay_requested)
	assert(current_scene.name == "Home")
	current_scene.free()
	print("PASS: damage, falls, respawn, protection, elimination, winner, draw, replay reset/countdown/freeze and return to Home")
	quit()
