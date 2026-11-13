extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	PlayerManager.clear_players()
	for slot in [0, 1, 3]:
		var device: int = slot - 1
		assert(PlayerManager.join_player(device, slot))
		var data := CharacterData.new()
		data.key = "Gunner" if slot != 1 else "Demolisher"
		data.character_scene = load("res://src/entities/prototypes/characters/%s.tscn" % data.key)
		PlayerManager.set_character(device, data)
		PlayerManager.set_ready(device, true)
		if device >= 0:
			MultiplayerInput.device_actions[device] = {}
			for action in MultiplayerInput.core_actions:
				MultiplayerInput.device_actions[device][action] = action
	var main = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	main.start_game()
	var hud = main.get_node("ArenaHUD")
	var feed: EliminationFeed = hud.elimination_feed
	feed.process_mode = Node.PROCESS_MODE_PAUSABLE
	feed.message_duration = 0.3
	var first: Penguin = main.players.get_child(0).get_child(0)
	var first_card: PlayerLivesCard = hud.cards[0]
	first.lose_life()
	assert(PlayerManager.get_lives(0) == 2)
	assert(not first_card.eliminated and not first_card.elimination_status.visible)
	assert(feed.get_child_count() == 0)
	first._on_respawn_timer_timeout()
	first.lose_life()
	first._on_respawn_timer_timeout()
	first.lose_life()
	assert(first.is_eliminated and first_card.eliminated)
	assert(first_card.elimination_status.visible and first_card.elimination_status.text == "Eliminated")
	assert(not first_card.weapon_status.visible and not first_card.weapon_meter.visible)
	assert(feed.get_child_count() == 1 and feed.get_child(0).text == "Player 1 eliminated!")
	assert(not main.round_finished)
	first_card.set_charge_progress(1.0, true)
	assert(not first_card.weapon_meter.visible)
	hud._on_lives_changed(0, 0)
	assert(feed.get_child_count() == 1)
	feed.announce(1)
	assert(feed.get_child_count() == 2 and feed.get_child(1).text == "Player 2 eliminated!")
	get_tree().paused = true
	await get_tree().create_timer(0.4).timeout
	assert(feed.get_child_count() == 2)
	get_tree().paused = false
	await get_tree().create_timer(0.4).timeout
	assert(feed.get_child_count() == 0 and first_card.elimination_status.visible)

	var last: Penguin = main.players.get_child(2).get_child(0)
	PlayerManager.set_lives(3, 1)
	last.lose_life()
	await get_tree().process_frame
	assert(main.round_finished and main.round_result.active)
	assert(main.round_result.title.text == "Player 2 wins!")
	assert(hud.cards[3].elimination_status.visible)
	assert(feed.get_child_count() == 1)
	get_tree().paused = false
	PlayerManager.reset_lives()
	hud.show_players(PlayerManager.players)
	assert(feed.get_child_count() == 0 and feed.announced_slots.is_empty())
	for card in hud.cards.values():
		assert(not card.eliminated and not card.elimination_status.visible)
	feed.announce(0)
	feed.announce(3)
	assert(feed.get_child_count() == 2)
	get_tree().current_scene = null
	main.free()
	PlayerManager.clear_players()
	print("PASS: temporary deaths stay unmarked, final lives announce once, simultaneous messages pause/expire, HUD remains eliminated, winner transition and reset work")
	get_tree().quit()
