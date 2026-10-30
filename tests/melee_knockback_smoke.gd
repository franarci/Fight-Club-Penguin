extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	manager.join_player(-1, 0)
	manager.join_player(0, 1)
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var attacker_scene = load("res://src/entities/prototypes/characters/Demolisher.tscn").instantiate()
	var target_scene = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	attacker_scene.get_child(0).setup(0, -1)
	# No controller input is required for the stationary target.
	target_scene.get_child(0).setup(1, -1)
	arena.add_child(attacker_scene)
	arena.add_child(target_scene)
	var attacker = attacker_scene.get_child(0)
	var target = target_scene.get_child(0)
	attacker.set_physics_process(false)
	target.set_physics_process(false)
	var weapon = attacker.current_weapon
	weapon.set_process(false)
	weapon.set_physics_process(false)
	target.current_weapon.set_process(false)
	weapon.melee_data = weapon.melee_data.duplicate()
	weapon.melee_data.windup_duration = 0
	weapon.melee_data.recovery_duration = 0
	weapon.melee_data.knockback = 180.0
	for i in range(8):
		var direction := Vector2.RIGHT.rotated(i * PI / 4.0)
		target.position = direction * 45.0
		target.set_health(100)
		target.velocity = Vector2.ZERO
		target.is_being_pushed = false
		weapon.can_attack = true
		weapon.cancel_attack()
		weapon.set_aim_direction(direction)
		await physics_frame
		await process_frame
		weapon.try_attack()
		weapon._physics_process(0.01)
		assert(target.current_health == 90)
		assert(target.velocity.is_equal_approx(direction * 180))
		assert(target.is_being_pushed)
		# A second overlap must not reset the push after friction slows it.
		target.velocity *= 0.5
		weapon._physics_process(0.01)
		assert(target.velocity.is_equal_approx(direction * 90))
	# Protected and zero-damage attacks must not push.
	for blocked_by in ["protection", "zero_damage", "zero_knockback"]:
		weapon.cancel_attack()
		weapon.can_attack = true
		target.velocity = Vector2.ZERO
		target.is_being_pushed = false
		target.set_health(100)
		target.protection_left = 1.0 if blocked_by == "protection" else 0.0
		weapon.melee_data.damage = 0.0 if blocked_by == "zero_damage" else 10.0
		weapon.melee_data.knockback = 0.0 if blocked_by == "zero_knockback" else 180.0
		weapon.try_attack()
		weapon._physics_process(0.01)
		assert(target.velocity == Vector2.ZERO and not target.is_being_pushed)
		assert(target.current_health == (90.0 if blocked_by == "zero_knockback" else 100.0))
	# Existing dash pushes still use the character's configured push speed.
	target.receive_push(Vector2.RIGHT)
	assert(target.velocity == Vector2.RIGHT * target.push_speed)
	target._physics_process(0.01)
	assert(target.velocity.length() < target.push_speed)
	# A lethal melee hit loses one life and leaves no lingering push.
	target.position = Vector2(1, -1).normalized() * 45.0
	await physics_frame
	await process_frame
	weapon.cancel_attack()
	weapon.can_attack = true
	weapon.melee_data.knockback = 180
	target.set_health(1)
	weapon.try_attack()
	weapon._physics_process(0.01)
	assert(target.is_dead and target.velocity == Vector2.ZERO)
	assert(not target.is_being_pushed and manager.get_lives(1) == 2)
	arena.free()
	print("PASS: eight knockback directions, one push per swing, protection, zero damage/strength, friction, dash compatibility and lethal hit")
	quit()
