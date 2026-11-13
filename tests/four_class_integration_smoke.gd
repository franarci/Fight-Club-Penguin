extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	PlayerManager.clear_players()
	for device in range(3):
		MultiplayerInput.device_actions[device] = {}
		for action in MultiplayerInput.core_actions:
			MultiplayerInput.device_actions[device][action] = action
	var main = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	var selection = main.character_select
	var names := ["Gunner", "Demolisher", "Scout", "Hunter"]
	for index in range(4):
		selection.activate_player_slot(index - 1)
		var card: PlayerSelection = selection.player_slots[index]
		card.selected_character = index
		card.update_character_preview()
		assert(card.player_label.text == names[index] and not card.select_button.disabled)
		card.confirm_character()
		assert(card.ready_badge.visible)
	selection._open_ready_dialog()
	selection.finish_character_selection()
	assert(main.players.get_child_count() == 4 and main.pre_match.active and get_tree().paused)
	main.pre_match.advance()
	main.pre_match.advance()
	for step in range(4):
		main.pre_match._on_countdown_timeout()
	assert(not get_tree().paused)
	var penguins: Array[Penguin] = []
	var boundary: CollisionPolygon2D = main.get_node("Arena/IceArea/Ground")
	for index in range(4):
		var character: Node2D = main.players.get_child(index)
		assert(character.name == names[index])
		var penguin: Penguin = character.get_child(0)
		penguins.append(penguin)
		assert(penguin.player_initialized)
		assert(Geometry2D.is_point_in_polygon(boundary.to_local(penguin.feet_marker.global_position), boundary.polygon))
	for player in main.players.find_children("*", "AudioStreamPlayer", true, false):
		assert(player.bus == &"FX")
	var scout_weapon := penguins[2].current_weapon as RangedWeapon
	assert(scout_weapon != null and scout_weapon.current_ammo == 1)
	var hud = main.get_node("ArenaHUD")
	assert(hud.cards[2].ammo_pips.single_bullet_mode)
	scout_weapon.attack()
	assert(scout_weapon.current_ammo == 0 and scout_weapon.reload_time_left > 0.0)
	assert(hud.cards[2].ammo_pips.current_ammo == 0)
	var hunter_weapon := penguins[3].current_weapon as HarpoonWeapon
	assert(hunter_weapon != null)
	hunter_weapon.launch_harpoon()
	assert(is_instance_valid(hunter_weapon.harpoon_projectile))
	var previous_health := penguins[0].current_health
	hunter_weapon.harpoon_projectile.hook_target(penguins[0])
	assert(penguins[0].current_health < previous_health and penguins[0].is_being_pushed)
	hunter_weapon.cancel_attack()
	assert(hunter_weapon.body.visible)
	penguins[2].lose_life()
	penguins[2].respawn_timer.stop()
	penguins[2]._on_respawn_timer_timeout()
	assert(scout_weapon.reload_time_left > 0.0)
	scout_weapon._process_magazine(scout_weapon.reload_time_left)
	assert(scout_weapon.current_ammo == 1 and scout_weapon.reload_time_left == 0.0)
	assert(Geometry2D.is_point_in_polygon(boundary.to_local(penguins[2].feet_marker.global_position), boundary.polygon))
	main._finish_round(0)
	main.round_result._on_replay_pressed()
	await get_tree().process_frame
	await get_tree().process_frame
	var replay = get_tree().current_scene
	assert(replay.players.get_child_count() == 4 and replay.pre_match.countdown_step == 0)
	for index in range(4):
		assert(replay.players.get_child(index).name == names[index])
	get_tree().paused = false
	replay.free()
	PlayerManager.clear_players()
	print("PASS: four selectable classes, profiles and READY, tutorial/countdown, equipped weapons, Scout reload/HUD/respawn, Hunter damage/pull, FX routing and four-class rematch")
	get_tree().quit()
