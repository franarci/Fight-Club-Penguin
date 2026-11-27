extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")

func make_match():
	get_tree().paused = false
	PlayerManager.clear_players()
	for slot in range(2):
		assert(PlayerManager.join_player(slot - 1, slot))
		var data := CharacterData.new()
		data.key = ["Hunter", "Demolisher"][slot]
		data.character_scene = load("res://src/entities/prototypes/characters/%s.tscn" % data.key)
		PlayerManager.set_character(slot - 1, data)
	var main = load("res://Main.tscn").instantiate()
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	main.start_game()
	return main

func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	MultiplayerInput.device_actions[0] = {}
	for action in MultiplayerInput.core_actions:
		MultiplayerInput.device_actions[0][action] = action
	var main = make_match()
	var winner: Penguin = main.players.get_child(0).get_child(0)
	winner.current_health = 63.0
	var camera: Camera2D = main.get_node("SharedCamera")
	var initial_zoom := camera.zoom
	main._finish_round(0)
	var result = main.round_result
	assert(main.round_finished and get_tree().paused)
	assert(result.presenting and not result.active)
	assert(not result.announcement.visible and not result.background.visible)
	assert(not winner.player_indicator.visible and result.celebration == null)
	assert(result.presentation_timer.is_stopped())
	assert(is_equal_approx(result.presentation_timer.wait_time, 5.0))
	assert(not main.get_node("ArenaHUD").visible)
	assert(result.announcement_title.text == "PLAYER 1 WINS!")
	var target: Vector2 = winner.body.to_global(winner.get_body_display_rect().get_center())
	var initial_distance := camera.global_position.distance_to(target)
	var time_left: float = result.presentation_timer.time_left
	result._on_replay_pressed()
	result._on_menu_pressed()
	main._finish_round(1)
	assert(get_tree().current_scene == main and not PlayerManager.replay_requested)
	assert(is_equal_approx(result.presentation_timer.time_left, time_left))
	await get_tree().create_timer(0.4).timeout
	assert(result.presenting and not result.active)
	assert(camera.zoom.x > initial_zoom.x and camera.zoom.x < 2.01)
	assert(camera.global_position.distance_to(target) < initial_distance)
	assert(winner.current_health == 63.0 and PlayerManager.get_lives(0) == 3)
	assert(not result.announcement.visible and result.celebration == null)
	await get_tree().create_timer(1.0).timeout
	assert(result.announcement.visible and result.celebration.running)
	assert(not winner.player_indicator.visible)
	assert(winner.body.position != result.celebration.body_position)
	await get_tree().create_timer(5.05).timeout
	assert(result.active and not result.presenting and result.background.visible)
	assert(not result.announcement.visible and result.replay_button.has_focus())
	assert(camera.global_position.distance_to(target) < 0.1)
	assert(camera.zoom.x <= 2.0)
	assert(result.announcement_title.get_theme_font_size("font_size") == 64)
	assert(result.announcement_title.get_minimum_size().x <= result.announcement_title.size.x)
	assert(winner.current_health == 63.0 and PlayerManager.get_lives(0) == 3)
	assert(result.celebration.running and not winner.player_indicator.visible)
	var celebration_elapsed: float = result.celebration.elapsed
	await get_tree().create_timer(0.12).timeout
	assert(result.celebration.elapsed > celebration_elapsed)
	result._on_replay_pressed()
	for index in range(4):
		await get_tree().process_frame
	main = get_tree().current_scene
	assert(main.pre_match.countdown_step == 0 and not main.round_result.presenting)
	assert(main.get_node("ArenaHUD").visible and main.get_node("SharedCamera").zoom.x < 2.0)
	for index in range(4):
		main.pre_match._on_countdown_timeout()
	var draw_camera: Camera2D = main.get_node("SharedCamera")
	var draw_zoom := draw_camera.zoom
	main._finish_round(-1)
	assert(main.round_result.presenting and main.round_result.announcement_title.text == "DRAW!")
	assert(main.round_result.focused_camera == null and draw_camera.zoom == draw_zoom)
	main.round_result._on_presentation_timeout()
	assert(main.round_result.active and main.round_result.title.text == "Draw!")
	main.free()
	main = make_match()
	winner = main.players.get_child(0).get_child(0)
	winner.is_dead = true
	winner.current_health = 0.0
	winner.hide()
	main._finish_round(0, "Time's up!")
	assert(winner.visible and winner.global_position == winner.respawn_position)
	assert(winner.is_dead and winner.current_health == 0.0 and PlayerManager.get_lives(0) == 3)
	assert(main.round_result.presenting)
	main.free()
	PlayerManager.clear_players()
	get_tree().paused = false
	print("PASS: zoom then five-second announcement and continuing celebration, hidden identifier, smooth centered zoom while paused, blocked early inputs, unchanged score, delayed results, rematch reset, draw and waiting-respawn winner")
	get_tree().quit()
