extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var names = ["Gunner", "Hunter", "Explorer", "Demolisher"]
	# Supply neutral action mappings for controller slots in headless tests.
	var input_manager = root.get_node("MultiplayerInput")
	for device in range(3):
		input_manager.device_actions[device] = {}
		for action in input_manager.core_actions:
			input_manager.device_actions[device][action] = action
	for slot in range(4):
		assert(manager.join_player(slot - 1, slot))
		var data := CharacterData.new()
		data.key = names[slot]
		manager.set_character(slot - 1, data)
	main.start_game()
	var penguins = []
	for character in main.players.get_children():
		var penguin = character.get_child(0)
		penguins.append(penguin)
		penguin.respawn_delay = 0.03
		penguin.respawn_protection = 0.2
		assert(penguin.current_health == 100.0 and main.get_node("ArenaHUD").cards[penguin.player_index].health_bar.value == 100.0)
	await process_frame
	var viewport_size := root.get_visible_rect().size
	for slot in range(4):
		var card = main.get_node("ArenaHUD").cards[slot]
		assert(Rect2(Vector2.ZERO, viewport_size).encloses(card.get_global_rect()))
		assert(card.health_bar.max_value == 100.0)
		assert(not penguins[slot].has_node("HealthBar"))
	await physics_frame
	await physics_frame
	var shooter = penguins[0]
	var target = penguins[1]
	var bullet = load("res://src/entities/prototypes/projectiles/RifleProjectile.tscn").instantiate()
	bullet.initialize(main, target.global_position + Vector2(-20, 15), Vector2.RIGHT, shooter, 1000.0, 30.0)
	bullet.set_physics_process(false)
	bullet._physics_process(0.05)
	assert(main.get_node("ArenaHUD").cards[0].health_bar.value == 100.0)
	assert(main.get_node("ArenaHUD").cards[1].health_label.text == "70 / 100")
	assert(target.current_health == 70.0 and main.get_node("ArenaHUD").cards[target.player_index].health_bar.value == 70.0)
	assert(manager.get_lives(1) == 3)
	target.receive_damage(0.0)
	target.receive_damage(-10.0)
	target.receive_damage(10.0, target)
	assert(target.current_health == 70.0)
	# A future melee source uses exactly the same damage entry point.
	target.receive_damage(70.0, shooter, Vector2.RIGHT)
	target.receive_damage(500.0, shooter)
	target.check_arena_bounds()
	assert(target.is_dead and manager.get_lives(1) == 2)
	assert(main.get_node("ArenaHUD").cards[target.player_index].health_bar.value == 0.0)
	assert(not main.get_node("ArenaHUD").cards[1].hearts[2].filled)
	await create_timer(0.1).timeout
	assert(not target.is_dead and target.current_health == 100.0)
	assert(main.get_node("ArenaHUD").cards[1].health_bar.value == 100.0)
	assert(target.global_position == target.respawn_position)
	assert(target.collision_layer == target.original_collision_layer)
	target.receive_damage(1000.0, shooter)
	assert(target.current_health == 100.0 and manager.get_lives(1) == 2)
	await create_timer(0.25).timeout
	target.receive_damage(1.0, shooter)
	assert(target.current_health == 99.0)
	target.receive_push(Vector2.RIGHT)
	target.global_position = Vector2(-100, -100)
	target.check_arena_bounds()
	target.check_arena_bounds()
	assert(manager.get_lives(1) == 1 and target.is_dead)
	assert(not target.is_being_pushed and target.velocity == Vector2.ZERO)
	await create_timer(0.1).timeout
	assert(target.current_health == 100.0 and not target.is_dead)
	assert(target.current_weapon.can_attack)
	# Falling bypasses damage protection and consumes the final life.
	target.global_position = Vector2(1100, 600)
	target.check_arena_bounds()
	target.check_arena_bounds()
	assert(manager.get_lives(1) == 0 and target.is_eliminated)
	await create_timer(0.1).timeout
	assert(main.get_node("ArenaHUD").cards[1].health_bar.value == 0.0)
	assert(target.is_dead and not target.visible and target.collision_layer == 0)
	assert(target.current_weapon.process_mode == Node.PROCESS_MODE_DISABLED)
	target.receive_damage(1000.0, shooter)
	assert(manager.get_lives(1) == 0)
	# Verify health/death wiring is shared by all four classes.
	for index in [0,2,3]:
		penguins[index].receive_damage(100.0)
		assert(manager.get_lives(index) == 2)
	await create_timer(0.1).timeout
	for index in [0,2,3]:
		assert(penguins[index].current_health == 100.0 and not penguins[index].is_dead)
	main.free()
	manager.clear_players()
	print("PASS: projectile HP/bar, shared damage, HUD lives, duplicate death guard, fall deaths, respawn/protection and elimination across four classes")
	quit()
