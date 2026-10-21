extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var character = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	character.get_child(0).setup(0, -1)
	root.add_child(character)
	var penguin = character.get_child(0)
	penguin.set_physics_process(false)
	var weapon = penguin.current_weapon
	weapon.set_process(false)
	var walk_names = ["walk_right", "walk_down_right", "walk_down", "walk_down_right", "walk_left", "walk_up", "walk_up", "walk_up"]
	for i in range(8):
		var direction := Vector2.RIGHT.rotated(i * PI / 4.0)
		penguin.update_facing(direction)
		penguin.play_animation(&"walk")
		assert(penguin.body.animation == walk_names[i])
		var pose = weapon.get_directional_poses()[i]
		assert(weapon.body.animation == pose.animation)
		assert(weapon.body.flip_h == pose.flip_h and weapon.body.flip_v == pose.flip_v)
		assert(weapon.body.flip_v == (i == 2))
		assert(weapon.z_index == (-1 if i >= 5 else 1))
		if i >= 5:
			var visible_pixels := exposed_pixels(weapon.body, penguin.body)
			print("Rifle rear pose %s: %d exposed pixels" % [pose.direction, visible_pixels])
			assert(visible_pixels > 10)
		penguin.play_animation(&"idle")
		assert(penguin.body.sprite_frames.get_frame_count(penguin.body.animation) > 0)
		penguin.play_animation(&"dash")
		assert(penguin.animation_player.is_playing())
		penguin.advance_dash_animation(penguin.dash_duration * 0.5)
		assert(penguin.weapon_socket.position == Vector2(0, 4))
		penguin.play_animation(&"idle")
		assert(penguin.weapon_socket.position == penguin.standing_weapon_position)
	character.free()
	print("PASS: Gunner eight directions, correct lower-diagonal art, upper fallback, rifle flips/layers/visibility and dash attachments")
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
