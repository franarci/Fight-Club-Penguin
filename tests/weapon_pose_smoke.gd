extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var character = load("res://src/entities/prototypes/characters/Demolisher.tscn").instantiate()
	root.add_child(character)
	var penguin = character.get_child(0)
	penguin.set_physics_process(false)
	var weapon = penguin.get_node("Weapon/EquippedWeapon")
	weapon.set_process(false)
	# Runtime setup must recover the profile even if the editor override is missing.
	weapon.visual_profile = null
	weapon.setup(-1, penguin.starting_weapon_data)
	var socket = penguin.get_node("Weapon")
	socket.position = Vector2(0, 4)
	for i in range(8):
		penguin.update_facing(Vector2.RIGHT.rotated(i * PI / 4.0))
		penguin.play_animation(&"walk")
		weapon.set_aim_direction(Vector2.RIGHT.rotated(i * PI / 4.0))
		var pose = weapon.get_directional_poses()[i]
		assert(weapon.body.animation == pose.animation)
		assert(weapon.body.flip_h == pose.flip_h)
		assert(not weapon.body.flip_v)
		var grip: Vector2 = pose.grip_offset
		if pose.flip_h:
			grip.x = -grip.x
		assert((weapon.body.position + grip * weapon.body.scale).is_equal_approx(pose.hand_position))
		assert(weapon.z_index == pose.layer)
		assert(socket.position == Vector2(0, 4))
		assert(weapon.body.sprite_frames.get_frame_count(pose.animation) > 0)
		if pose.layer < 0:
			var exposed := exposed_pixels(weapon.body, penguin.body)
			print("Rear pose %s: %d exposed source pixels" % [pose.direction, exposed])
			assert(exposed > 20, "Rear-facing hammer is fully hidden by the body")
	character.free()
	var rifle = load("res://src/entities/prototypes/weapons/ranged/RangedWeapon.tscn").instantiate()
	root.add_child(rifle)
	rifle.set_process(false)
	assert(rifle.directional_poses.is_empty())
	rifle.set_aim_direction(Vector2.DOWN)
	assert(rifle.body.animation == &"idle_up" and rifle.body.flip_v)
	rifle.free()
	print("PASS: eight hammer poses, anchored grips, layers, dash socket preserved and rifle fallback unchanged")
	quit()

func exposed_pixels(weapon: AnimatedSprite2D, body: AnimatedSprite2D) -> int:
	var weapon_image := weapon.sprite_frames.get_frame_texture(weapon.animation, 0).get_image()
	var body_image := body.sprite_frames.get_frame_texture(body.animation, 0).get_image()
	var exposed := 0
	for y in range(0, weapon_image.get_height(), 4):
		for x in range(0, weapon_image.get_width(), 4):
			if weapon_image.get_pixel(x, y).a < 0.5:
				continue
			var point := Vector2(x, y) - Vector2(weapon_image.get_size()) / 2.0
			if weapon.flip_h:
				point.x = -point.x
			var body_point := body.to_local(weapon.to_global(point))
			if body.flip_h:
				body_point.x = -body_point.x
			var pixel := Vector2i(body_point + Vector2(body_image.get_size()) / 2.0)
			if not Rect2i(Vector2i.ZERO, body_image.get_size()).has_point(pixel) or body_image.get_pixelv(pixel).a < 0.5:
				exposed += 1
	return exposed
