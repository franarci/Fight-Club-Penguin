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
	weapon.wielder = penguin
	weapon.setup(-1, penguin.starting_weapon_data)
	weapon.set_physics_process(false)
	# Test a saved down animation and an in-memory up animation if not saved yet.
	weapon.body.sprite_frames = weapon.body.sprite_frames.duplicate()
	var frames: SpriteFrames = weapon.body.sprite_frames
	if not frames.has_animation(&"attack_up"):
		frames.add_animation(&"attack_up")
		for i in range(frames.get_frame_count(&"attack_down")):
			frames.add_frame(&"attack_up", frames.get_frame_texture(&"attack_down", i))
	for direction in [Vector2.UP, Vector2.DOWN]:
		weapon.can_attack = true
		weapon.set_aim_direction(direction)
		var idle: StringName = weapon.body.animation
		var position: Vector2 = weapon.body.position
		weapon.try_attack()
		assert(weapon.body.animation == (&"attack_up" if direction.y < 0 else &"attack_down"))
		assert(weapon.body.frame == 0)
		weapon.apply_swing_visual(weapon.swing_windup + 0.01, weapon.melee_data)
		assert(weapon.body.frame == 1)
		assert(weapon.body.rotation == 0)
		if direction == Vector2.DOWN:
			assert(weapon.body.position.y > position.y)
			weapon.apply_swing_visual(weapon.swing_windup + weapon.swing_active_duration, weapon.melee_data)
			assert(weapon.body.position.is_equal_approx(position + weapon.melee_data.down_attack_offset))
			weapon.apply_swing_visual(weapon.swing_windup + weapon.swing_active_duration + weapon.swing_recovery * 0.5, weapon.melee_data)
			assert(weapon.body.position.is_equal_approx(position + weapon.melee_data.down_attack_offset * 0.5))
		else:
			assert(weapon.body.position == position)
		assert(not weapon.body.flip_h and not weapon.body.flip_v)
		assert(not weapon.body.is_playing(), "Physics timeline owns playback")
		weapon.cancel_attack()
		assert(weapon.body.animation == idle and weapon.body.is_playing())
		assert(weapon.body.position == position)
	character.free()
	print("PASS: authored up/down frames, no extra rotation/flips, impact timing and idle restoration")
	quit()
