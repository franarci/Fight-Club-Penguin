extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	for character in ["Gunner", "Demolisher"]:
		var scene = load("res://src/entities/prototypes/characters/%s.tscn" % character).instantiate()
		var penguin = scene.get_child(0)
		var original_data = penguin.starting_weapon_data
		penguin.starting_weapon_data = null
		penguin.setup(0, -1)
		root.add_child(scene)
		penguin.set_physics_process(false)
		var weapon = penguin.current_weapon
		weapon.set_process(false)
		assert(weapon.weapon_data == original_data)
		assert(weapon.body.sprite_frames == original_data.sprite_frames)
		var packed = load(weapon.scene_file_path)
		var standalone = packed.instantiate()
		root.add_child(standalone)
		standalone.set_process(false)
		# An unattached weapon previews its legacy poses; character instances use hand attachments.
		standalone.wielder = null
		standalone.setup(-1, standalone.default_weapon_data)
		assert(standalone.scale == weapon.scale)
		for i in range(8):
			var direction = Vector2.RIGHT.rotated(i * PI / 4.0)
			weapon.set_aim_direction(direction)
			standalone.set_aim_direction(direction)
			assert(standalone.body.position.is_equal_approx(weapon.body.position))
			assert(standalone.body.animation == weapon.body.animation)
			assert(standalone.body.flip_h == weapon.body.flip_h)
			assert(standalone.body.flip_v == weapon.body.flip_v)
			assert(standalone.z_index == weapon.z_index)
		standalone.free()
		scene.free()
	print("PASS: standalone weapons match character weapon poses and initialize from scene defaults")
	quit()
