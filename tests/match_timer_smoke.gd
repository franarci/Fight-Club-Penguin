extends Node

var clock_expirations := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	var clock = load("res://src/ui/arena/MatchClock.tscn").instantiate()
	clock.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(clock)
	clock.expired.connect(func(): clock_expirations += 1)
	assert(not clock.visible and clock.text == "5:00" and clock.timer.is_stopped())
	clock.timer.wait_time = 0.3
	clock.start()
	await get_tree().create_timer(0.07).timeout
	assert(clock.visible and clock.timer.time_left < 0.3 and clock.timer.time_left > 0.0)
	get_tree().paused = true
	var paused_time: float = clock.timer.time_left
	await get_tree().create_timer(0.1).timeout
	assert(is_equal_approx(clock.timer.time_left, paused_time))
	get_tree().paused = false
	await get_tree().create_timer(0.4).timeout
	assert(clock_expirations == 1 and clock.text == "0:00")
	clock.start()
	assert(clock.timer.is_stopped() and clock_expirations == 1)
	clock.free()

	var main = create_match()
	assert(not main.match_clock.started and not main.match_clock.visible)
	assert(main.match_clock.timer.wait_time == 300.0)
	assert(get_tree().paused and main.pre_match.active)
	main.pre_match.advance()
	main.pre_match.advance()
	for step in range(3):
		main.pre_match._on_countdown_timeout()
		assert(not main.match_clock.started)
	main.pre_match._on_countdown_timeout()
	assert(main.match_clock.started and main.match_clock.visible and not get_tree().paused)
	assert(main.match_clock.text == "5:00")
	assert(is_equal_approx(main.match_clock.get_global_rect().get_center().x, get_viewport().get_visible_rect().size.x * 0.5))
	assert(main.match_clock.get_global_rect().position.y >= 0.0)
	PlayerManager.set_lives(0, 3)
	PlayerManager.set_lives(2, 2)
	penguin(main, 0).current_health = 1.0
	penguin(main, 1).current_health = 100.0
	main._on_time_limit_reached()
	assert(main.round_result.title.text == "Player 1 wins!")
	assert(main.round_result.reason_label.text == "Time's up! Most lives remaining.")
	assert(main.round_finished and get_tree().paused and main.match_clock.timer.paused)
	main._on_time_limit_reached()
	main._check_round_result()
	assert(main.round_result.title.text == "Player 1 wins!")
	main.round_result._on_replay_pressed()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	main = get_tree().current_scene
	main.process_mode = Node.PROCESS_MODE_DISABLED
	assert(main.pre_match.countdown_step == 0 and get_tree().paused)
	assert(not main.match_clock.started and main.match_clock.text == "5:00")
	assert(PlayerManager.get_lives(0) == 3 and PlayerManager.get_lives(2) == 3)
	for step in range(4):
		main.pre_match._on_countdown_timeout()
	assert(main.match_clock.started and main.match_clock.text == "5:00")
	cleanup_match(main)

	main = create_match()
	penguin(main, 0).current_health = 20.0
	penguin(main, 1).current_health = 80.0
	main._on_time_limit_reached()
	assert(main.round_result.title.text == "Player 3 wins!")
	assert(main.round_result.reason_label.text == "Time's up! Highest HP after tied lives.")
	cleanup_match(main)

	main = create_match()
	main._on_time_limit_reached()
	assert(main.round_result.title.text == "Draw!")
	assert(main.round_result.reason_label.text == "Time's up! Equal lives and HP.")
	cleanup_match(main)

	main = create_match()
	penguin(main, 0).is_dead = true
	penguin(main, 0).current_health = 0.0
	penguin(main, 0).hide()
	penguin(main, 1).current_health = 80.0
	main._on_time_limit_reached()
	assert(main.round_result.title.text == "Player 1 wins!")
	cleanup_match(main)

	main = create_match()
	main._on_time_limit_reached.call_deferred()
	PlayerManager.set_lives(0, 0)
	main._on_player_eliminated(0)
	PlayerManager.set_lives(2, 0)
	main._on_player_eliminated(2)
	await get_tree().process_frame
	assert(main.round_result.title.text == "Draw!")
	assert(not main.round_result.reason_label.visible)
	cleanup_match(main)

	main = create_match()
	PlayerManager.set_lives(0, 0)
	main._check_round_result()
	assert(main.round_result.title.text == "Player 3 wins!")
	assert(not main.round_result.reason_label.visible)
	cleanup_match(main)
	print("PASS: clock starts after GO, pauses, expires once, resolves lives/HP/draw/respawn, handles simultaneous elimination and resets on rematch")
	get_tree().quit()


func create_match() -> Node:
	get_tree().paused = false
	PlayerManager.clear_players()
	MultiplayerInput.device_actions[0] = {}
	for action in MultiplayerInput.core_actions:
		MultiplayerInput.device_actions[0][action] = action
	for entry in [{"device": -1, "slot": 0, "key": "Gunner"}, {"device": 0, "slot": 2, "key": "Demolisher"}]:
		assert(PlayerManager.join_player(entry.device, entry.slot))
		var data := CharacterData.new()
		data.key = entry.key
		PlayerManager.set_character(entry.device, data)
		PlayerManager.set_ready(entry.device, true)
	var main = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	main.prepare_match()
	return main


func penguin(main: Node, index: int) -> Penguin:
	return main.players.get_child(index).get_child(0) as Penguin


func cleanup_match(main: Node) -> void:
	get_tree().paused = false
	get_tree().current_scene = null
	main.free()
	PlayerManager.clear_players()
