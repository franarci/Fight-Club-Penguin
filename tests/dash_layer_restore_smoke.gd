extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	scene.get_child(0).setup(0, -1)
	root.add_child(scene)
	var penguin = scene.get_child(0)
	penguin.set_physics_process(false)
	penguin.current_weapon.set_process(false)
	for fraction in [0.3, 1.0]:
		penguin.update_facing(Vector2(1, -1))
		var standing_position: Vector2 = penguin.current_weapon.body.global_position
		penguin.play_animation(&"dash")
		assert(penguin.current_weapon.z_index == 1)
		penguin.advance_dash_animation(penguin.dash_duration * fraction)
		if fraction == 1.0:
			assert(penguin.current_weapon.body.global_position.is_equal_approx(standing_position), "Final dash key must return to the standing pose")
		penguin.play_animation(&"idle")
		assert(penguin.current_weapon.z_index == -1)
		assert(penguin.current_weapon.body.global_position.is_equal_approx(standing_position), "Dash exit must preserve the standing weapon position")
	# Restore the current direction, not a stale layer captured before dashing.
	penguin.play_animation(&"dash")
	penguin.update_facing(Vector2.RIGHT)
	penguin.play_animation(&"walk")
	assert(penguin.current_weapon.z_index == 1)
	scene.free()
	print("PASS: up-right rifle layer restores on completed/interrupted dash and respects new direction")
	quit()
