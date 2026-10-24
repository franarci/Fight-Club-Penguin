extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene = load("res://src/entities/prototypes/characters/Demolisher.tscn").instantiate()
	var penguin = scene.get_child(0)
	penguin.setup(0, -1)
	root.add_child(scene)
	penguin.set_physics_process(false)
	for weapon_path in ["melee/Hammer.tscn", "ranged/Rifle.tscn"]:
		assert(penguin.equip_weapon(load("res://src/entities/prototypes/weapons/" + weapon_path)))
		penguin.current_weapon.set_process(false)
		var expected_animations = ["dash_right", "dash_down_right", "dash_down", "dash_down_right", "dash_left", "dash_up_right", "dash_up", "dash_up_right"]
		for index in range(8):
			penguin.update_facing(Vector2.RIGHT.rotated(index * PI / 4.0))
			for duration in [0.18, 0.6]:
				penguin.dash_duration = duration
				var resting: Vector2 = penguin.current_weapon.body.global_position
				penguin.play_animation(&"dash")
				assert(penguin.dash_pose_active)
				assert(penguin.body.animation == expected_animations[index])
				assert(penguin.body.flip_h == (index in [3, 4, 5]))
				for frame in range(4):
					if frame > 0:
						penguin.advance_dash_animation(duration * 0.25)
					assert(penguin.body.frame == frame)
					assert(penguin.weapon_socket.position.is_equal_approx(Vector2(15 if index == 6 else 0, 7)))
					assert(penguin.arm.position.is_equal_approx(penguin.standing_arm_position + Vector2(0, 6)))
					assert(penguin.current_weapon.body.global_position.is_equal_approx(resting + penguin.global_transform.basis_xform(Vector2(15 if index == 6 else 0, 7))))
				penguin.advance_dash_animation(duration * 0.25)
				penguin.play_animation(&"idle")
				assert(penguin.current_weapon.body.global_position.is_equal_approx(resting))
				assert(penguin.arm.position.is_equal_approx(penguin.standing_arm_position))
				penguin.play_animation(&"dash")
				penguin.advance_dash_animation(duration * 0.3)
				penguin.play_animation(&"walk")
				assert(penguin.weapon_socket.position == penguin.standing_weapon_position)
				assert(penguin.arm.position.is_equal_approx(penguin.standing_arm_position))
	scene.free()
	print("PASS: Demolisher eight-direction dash coordinates four body frames, both weapons and arm; completion and interruption restore at both durations")
	quit()

