extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var cases = [
		[Vector2.RIGHT, "idle_right", false, false],
		[Vector2.LEFT, "idle_right", true, false],
		[Vector2.UP, "idle_up", false, false],
		[Vector2.DOWN, "idle_up", false, true],
		[Vector2(-1,-1), "idle_up_left", false, false],
		[Vector2(1,-1), "idle_up_left", true, false],
		[Vector2(-1,1), "idle_down_right", true, false],
		[Vector2(1,1), "idle_down_right", false, false],
	]
	for character_name in ["Gunner", "Hunter", "Explorer", "Demolisher"]:
		var character = load("res://src/entities/prototypes/characters/" + character_name + ".tscn").instantiate()
		var penguin = character.get_child(0)
		var weapon = penguin.get_node("Weapon/EquippedWeapon")
		weapon.position = Vector2(4,8)
		weapon.scale = Vector2(0.7,0.7)
		penguin.setup(0,-1)
		root.add_child(character)
		assert(penguin.current_weapon == weapon)
		assert(penguin.weapon_socket.get_child_count() == 1)
		assert(weapon.position == Vector2(4,8) and weapon.scale == Vector2(0.7,0.7))
		for entry in cases:
			penguin.update_facing(entry[0])
			assert(weapon.z_index == (-2 if entry[0] == Vector2.LEFT else (-1 if entry[0].y < 0 else 1)))
			assert(weapon.body.animation == entry[1])
			assert(weapon.body.flip_h == entry[2] and weapon.body.flip_v == entry[3])
			var offset = weapon.upward_visual_offset if entry[0] == Vector2.UP else Vector2.ZERO
			assert(weapon.body.position == weapon.authored_body_position + offset)
			assert(weapon.body.sprite_frames.get_frame_count(entry[1]) > 0)
		penguin.update_facing(Vector2.ZERO)
		assert(weapon.direction_8 == Vector2i(1,1))
		var count_before := arena.get_child_count()
		weapon.try_attack()
		assert(arena.get_child_count() == count_before + 1)
		var projectile = arena.get_child(arena.get_child_count() - 1)
		assert(projectile is Projectile and projectile.shooter == penguin)
		assert(projectile.damage == weapon.ranged_data.damage)
		assert(projectile.speed == weapon.ranged_data.projectile_speed)
		assert(projectile.global_position.is_equal_approx(weapon.global_position + weapon.aim_direction * weapon.ranged_data.muzzle_distance))
		weapon.try_attack()
		assert(arena.get_child_count() == count_before + 1)
		projectile.free()
		character.free()
	arena.free()
	print("PASS: four characters, eight aim directions, saved transforms, no duplicate weapon")
	quit()
