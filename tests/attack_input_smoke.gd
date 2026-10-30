extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var characters: Array[Node] = []
	for name in ["Demolisher", "Gunner"]:
		var character = load("res://src/entities/prototypes/characters/%s.tscn" % name).instantiate()
		character.get_child(0).setup(characters.size(), -1)
		arena.add_child(character)
		characters.append(character)
		character.get_child(0).set_physics_process(false)
	var melee = characters[0].get_child(0)
	var gunner = characters[1].get_child(0)
	gunner.position = Vector2(45, 0)
	await physics_frame
	await physics_frame
	var event := InputEventKey.new()
	event.physical_keycode = KEY_F
	event.keycode = KEY_F
	event.pressed = true
	await process_frame
	Input.parse_input_event(event)
	for tick in range(12):
		await physics_frame
		await process_frame
	print("INPUT RESULT: melee_data=%s active=%s targetHP=%s ranged_data=%s projectile=%s" % [melee.current_weapon.melee_data != null, melee.current_weapon.swing_time_left, gunner.current_health, gunner.current_weapon.ranged_data != null, gunner.current_weapon.ranged_data.projectile_scene])
	var projectile_count := 0
	for child in arena.get_children():
		if child is Projectile:
			projectile_count += 1
	print("PROJECTILES: ", projectile_count)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	var passed: bool = gunner.current_health < gunner.max_health and projectile_count > 0
	gunner.current_weapon.set_process(false)
	for i in range(8):
		await create_timer(1.1).timeout
		var direction := Vector2.RIGHT.rotated(i * PI / 4.0)
		gunner.position = direction * 45.0
		gunner.set_health(gunner.max_health)
		melee.update_facing(direction)
		await physics_frame
		await process_frame
		var press := InputEventKey.new()
		press.physical_keycode = KEY_F
		press.keycode = KEY_F
		press.pressed = true
		Input.parse_input_event(press)
		for tick in range(12):
			await physics_frame
			await process_frame
		var hit: bool = gunner.current_health < gunner.max_health
		print("Actual character direction %d hit: %s" % [i, hit])
		passed = passed and hit
		var release := InputEventKey.new()
		release.physical_keycode = KEY_F
		release.keycode = KEY_F
		Input.parse_input_event(release)
	arena.free()
	quit(0 if passed else 1)
