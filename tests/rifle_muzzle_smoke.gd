extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	scene.get_child(0).setup(0, -1)
	root.add_child(scene)
	current_scene = scene
	var penguin = scene.get_child(0)
	penguin.set_physics_process(false)
	var weapon = penguin.current_weapon
	weapon.set_process(false)
	for index in range(8):
		penguin.update_facing(Vector2.RIGHT.rotated(index * PI / 4.0))
		var pose = weapon.get_directional_poses()[index]
		var point: Vector2 = pose.muzzle_offset
		if weapon.body.flip_h:
			point.x *= -1
		if weapon.body.flip_v:
			point.y *= -1
		var expected: Vector2 = weapon.body.to_global(point)
		weapon.attack()
		var bullet = scene.get_child(scene.get_child_count() - 1)
		assert(bullet is Projectile)
		assert(bullet.global_position.is_equal_approx(expected), "Bullet must spawn at the sprite muzzle")
		bullet.free()
		var before: Vector2 = weapon.get_muzzle_global_position()
		penguin.weapon_socket.position += Vector2(3, 7)
		var displacement: Vector2 = penguin.global_transform.basis_xform(Vector2(3, 7))
		assert(weapon.get_muzzle_global_position().is_equal_approx(before + displacement))
		penguin.weapon_socket.position -= Vector2(3, 7)
	# Preserve distance-based spawning for other weapons without configured muzzles.
	weapon.visual_profile = null
	weapon.directional_poses.clear()
	assert(weapon.get_muzzle_global_position().is_equal_approx(weapon.global_position + weapon.aim_direction * weapon.ranged_data.muzzle_distance))
	scene.free()
	print("PASS: all eight rifle muzzles spawn bullets correctly and follow socket transforms; legacy fallback preserved")
	quit()
