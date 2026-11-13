extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")


func run_checks() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	PlayerManager.clear_players()
	var main = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	for device in range(3):
		MultiplayerInput.device_actions[device] = {}
		for action in MultiplayerInput.core_actions:
			MultiplayerInput.device_actions[device][action] = action
	var selector = main.character_select
	for index in range(4):
		selector.activate_player_slot(index - 1)
		var card: PlayerSelection = selector.player_slots[index]
		card.selected_character = index
		card.update_character_preview()
		card.confirm_character()
	main.start_game()
	var penguins: Array[Penguin] = []
	var ground: CollisionPolygon2D = main.get_node("Arena/IceArea/Ground")
	for character in main.players.get_children():
		var penguin: Penguin = character.get_child(0)
		penguins.append(penguin)
		assert(SafeSpawn.can_spawn(penguin, ground, penguin.global_position, penguin.respawn_margin, penguin.respawn_clearance))
	var camera = main.get_node("SharedCamera")
	var original_zoom: Vector2 = camera.zoom
	penguins[0].lose_life()
	penguins[0].respawn_timer.stop()
	camera._update_frame(1.0 / 60.0, false)
	assert(camera.zoom.is_equal_approx(original_zoom))
	penguins[0].preferred_respawn_position = ground.to_global(Vector2(-10000, -10000))
	penguins[0]._on_respawn_timer_timeout()
	assert(not penguins[0].is_dead)
	assert(SafeSpawn.can_spawn(penguins[0], ground, penguins[0].global_position, 36.0, 64.0))
	penguins[0].check_arena_bounds()
	penguins[0].check_arena_bounds()
	assert(PlayerManager.get_lives(0) == 2)
	penguins[0].preferred_respawn_position = penguins[1].global_position
	penguins[0].lose_life()
	penguins[0].respawn_timer.stop()
	penguins[0]._on_respawn_timer_timeout()
	assert(penguins[0].feet_marker.global_position.distance_to(penguins[1].feet_marker.global_position) >= 64.0)
	penguins[2].respawn_margin = 10000.0
	penguins[2].lose_life()
	for index in range(3):
		penguins[2]._on_respawn_timer_timeout()
		assert(penguins[2].is_dead and PlayerManager.get_lives(2) == 2)
	penguins[2].respawn_timer.stop()
	penguins[2].respawn_margin = 36.0
	penguins[2]._on_respawn_timer_timeout()
	assert(not penguins[2].is_dead)
	var near: Array[Vector2] = [Vector2(800, 500), Vector2(850, 520)]
	camera.frame_points(near, 0.0, true)
	var previous_zoom: float = camera.zoom.x
	for step in range(120):
		var points: Array[Vector2] = [Vector2(800 - step * 3, 500), Vector2(850 + step * 3, 520)]
		camera.frame_points(points, 1.0 / 60.0)
		assert(absf(camera.zoom.x - previous_zoom) < 0.06)
		previous_zoom = camera.zoom.x
	var wide_zoom: float = camera.zoom.x
	camera.frame_points(near, 1.0 / 60.0)
	assert(is_equal_approx(camera.zoom.x, wide_zoom))
	for index in range(120):
		camera.frame_points(near, 1.0 / 60.0)
	assert(camera.zoom.x > wide_zoom)
	var first = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	var second = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	add_child(first)
	add_child(second)
	var pusher: Penguin = first.get_child(0)
	var receiver: Penguin = second.get_child(0)
	for penguin in [pusher, receiver]:
		penguin.set_physics_process(false)
		penguin.protection_left = 0.0
	pusher.global_position = Vector2(-5000, -5000)
	receiver.global_position = Vector2(-4946, -5000)
	var start := receiver.global_position
	var health := receiver.current_health
	await get_tree().physics_frame
	for index in range(90):
		pusher.velocity = Vector2(180, 0)
		pusher.move_and_slide()
		pusher.check_contact_push(Vector2(180, 0), 1.0 / 60.0)
		receiver.apply_ice_friction(1.0 / 60.0)
		receiver.move_and_slide()
		await get_tree().physics_frame
	assert(receiver.global_position.x > start.x + 35)
	assert(receiver.global_position.x < start.x + 130)
	assert(receiver.current_health == health and not receiver.is_being_pushed)
	assert(receiver.velocity.length() <= receiver.contact_push_speed)
	receiver.velocity = Vector2.ZERO
	receiver.mass = 2.0
	receiver.receive_contact_push(Vector2.RIGHT, 180, 1.0 / 60.0)
	assert(receiver.velocity.x <= receiver.contact_push_acceleration / 120.0)
	receiver.receive_push(Vector2.RIGHT)
	assert(receiver.is_being_pushed and receiver.velocity.x > receiver.contact_push_speed)
	first.free()
	second.free()
	main.free()
	PlayerManager.clear_players()
	print("PASS: safe shoreline/occupied respawns, retry without life loss, stable death framing, gradual zoom with delay, physical gentle contact without damage, mass and strong dash push")
	get_tree().quit()
