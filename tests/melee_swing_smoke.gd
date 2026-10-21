extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var characters: Array[Node] = []
	for name in ["Demolisher", "Gunner"]:
		var scene = load("res://src/entities/prototypes/characters/%s.tscn" % name).instantiate()
		scene.get_child(0).setup(characters.size(), -1)
		arena.add_child(scene)
		var penguin = scene.get_child(0)
		penguin.set_physics_process(false)
		penguin.current_weapon.set_process(false)
		penguin.current_weapon.set_physics_process(false)
		characters.append(penguin)
	var attacker = characters[0]
	var target = characters[1]
	var weapon = attacker.current_weapon
	weapon.melee_data = weapon.melee_data.duplicate()
	weapon.melee_data.windup_duration = 0.1
	weapon.melee_data.attack_duration = 0.25
	weapon.melee_data.recovery_duration = 0.15
	for i in range(8):
		var direction := Vector2.RIGHT.rotated(i * PI / 4.0)
		target.position = direction * 45
		target.set_health(100)
		target.velocity = Vector2.ZERO
		weapon.can_attack = true
		weapon.attack_cooldown.stop()
		attacker.update_facing(direction)
		var swing_facing: StringName = attacker.facing
		var rest_position: Vector2 = weapon.body.position
		var socket_position: Vector2 = attacker.weapon_socket.position
		await physics_frame
		await process_frame
		weapon.try_attack()
		attacker.update_facing(-direction)
		assert(attacker.facing == swing_facing, "Penguin facing must stay locked during wind-up")
		var hand: Vector2 = weapon.resting_body_position + weapon.swing_grip
		weapon._physics_process(0.05)
		assert(target.current_health == 100, "Wind-up must not damage")
		var authored: bool = weapon.direction_8.x == 0 and weapon.body.sprite_frames.has_animation("attack_down" if weapon.direction_8.y > 0 else "attack_up")
		assert(is_zero_approx(weapon.body.rotation) if authored else not is_zero_approx(weapon.body.rotation))
		assert((weapon.body.position + weapon.swing_grip.rotated(weapon.body.rotation)).is_equal_approx(hand))
		weapon.set_aim_direction(-direction)
		assert(weapon.aim_direction.is_equal_approx(direction), "Swing aim must stay locked")
		weapon._physics_process(0.06)
		attacker.update_facing(-direction)
		assert(attacker.facing == swing_facing, "Penguin facing must stay locked during impact")
		assert(target.current_health == 90, "Impact window must damage")
		weapon._physics_process(0.25)
		attacker.update_facing(-direction)
		assert(attacker.facing == swing_facing, "Penguin facing must stay locked during recovery")
		assert(target.current_health == 90, "One hit per swing")
		# New overlap during recovery must not receive damage.
		weapon.hit_targets.clear()
		weapon._physics_process(0.05)
		assert(target.current_health == 90, "Recovery must not damage")
		weapon._physics_process(0.1)
		assert(weapon.swing_time_left == 0)
		assert(is_zero_approx(weapon.body.rotation))
		assert(weapon.aim_direction.is_equal_approx(-direction))
		assert(attacker.weapon_socket.position == socket_position)
		assert(not weapon.can_attack and not weapon.attack_cooldown.is_stopped())
		attacker.update_facing(-direction)
		assert(attacker.facing != swing_facing, "Facing must unlock before the cooldown ends")
		# Interrupted swings restore the exact resting pose, including grip position.
		weapon.attack_cooldown.stop()
		weapon.can_attack = true
		weapon.set_aim_direction(direction)
		weapon.try_attack()
		weapon._physics_process(0.05)
		weapon.cancel_attack()
		assert(weapon.body.position.is_equal_approx(rest_position))
		assert(is_zero_approx(weapon.body.rotation))
		attacker.update_facing(direction)
		assert(attacker.facing == swing_facing, "Cancelled swings must release facing")
	# A slow physics frame crossing the entire impact window must still hit once.
	target.set_health(100)
	weapon.can_attack = true
	weapon.try_attack()
	weapon._physics_process(1.0)
	assert(target.current_health == 90)
	arena.free()
	print("PASS: eight animated swings, grip anchors, wind-up/impact/recovery windows, aim lock, cooldown, cancellation and long-frame impact")
	quit()
