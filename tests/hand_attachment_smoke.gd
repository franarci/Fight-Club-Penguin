extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	for character in ["Gunner", "Demolisher"]:
		var scene = load("res://src/entities/prototypes/characters/%s.tscn" % character).instantiate()
		var penguin = scene.get_child(0)
		penguin.setup(0, -1)
		root.add_child(scene)
		penguin.set_physics_process(false)
		for path in ["melee/Hammer.tscn", "ranged/Rifle.tscn"]:
			assert(penguin.equip_weapon(load("res://src/entities/prototypes/weapons/" + path)))
			var weapon = penguin.current_weapon
			for i in range(8):
				penguin.update_facing(Vector2.RIGHT.rotated(i * PI / 4.0))
				if character == "Demolisher" and i in [3, 4, 5]:
					assert(weapon.z_index == -1)
					weapon.z_index = 1
					weapon.restore_directional_layer()
					assert(weapon.z_index == -1)
				var pose = weapon.get_directional_poses()[i]
				var grip: Vector2 = pose.grip_offset
				if weapon.body.flip_h: grip.x *= -1
				if weapon.body.flip_v: grip.y *= -1
				var expected: Vector2 = penguin.weapon_socket.to_global(penguin.hand_positions.get(weapon.POSE_DIRECTIONS[i]))
				assert(weapon.body.to_global(grip).is_equal_approx(expected), "Weapon grip must meet the character hand")
				penguin.weapon_socket.position += Vector2(0, 4)
				weapon.set_aim_direction(weapon.aim_direction)
				expected = penguin.weapon_socket.to_global(penguin.hand_positions.get(weapon.POSE_DIRECTIONS[i]))
				assert(weapon.body.to_global(grip).is_equal_approx(expected))
				penguin.weapon_socket.position -= Vector2(0, 4)
		scene.free()
	print("PASS: both weapons meet both characters' hands in eight directions and follow socket movement")
	quit()
