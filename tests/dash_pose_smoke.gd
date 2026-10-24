extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var character = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	var penguin = character.get_child(0)
	penguin.setup(0,-1)
	arena.add_child(character)
	penguin.set_physics_process(false)
	for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		for duration in [0.18, 0.5, 1.0]:
			penguin.dash_duration = duration
			penguin.update_facing(direction)
			penguin.dash_direction = direction
			penguin.movement_state_machine.change_state(&"Dash")
			assert(not penguin.body.is_playing())
			assert(penguin.weapon_socket.position == Vector2(0,4))
			var dash = penguin.movement_state_machine.current_state
			for step in range(3):
				dash.physics_update(duration / 4.0)
				assert(penguin.body.animation == String("dash_") + String(penguin.facing))
				assert(penguin.body.frame == step + 1)
				assert(penguin.weapon_socket.position == Vector2(0,4))
				assert(penguin.arm.position.is_equal_approx(Vector2(-1.3333334,12)))
			dash.physics_update(duration / 4.0 + 0.00001)
			assert(penguin.movement_state_machine.current_state.name == &"Idle")
			assert(penguin.weapon_socket.position == penguin.standing_weapon_position)
			assert(penguin.arm.position == penguin.standing_arm_position)
			assert(penguin.body.animation == String("idle_") + String(penguin.facing))
			assert(penguin.body.is_playing())
	penguin.movement_state_machine.change_state(&"Dash")
	penguin.receive_push(Vector2.LEFT)
	assert(not penguin.animation_player.is_playing())
	assert(penguin.weapon_socket.position == penguin.standing_weapon_position)
	assert(penguin.current_weapon.transform.y == Vector2.DOWN)
	character.free()
	for name in ["Hunter","Explorer","Demolisher"]:
		var other = load("res://src/entities/prototypes/characters/" + name + ".tscn").instantiate()
		var body = other.get_child(0)
		body.setup(0,-1)
		arena.add_child(other)
		body.update_facing(Vector2.RIGHT)
		body.play_animation(&"dash")
		assert(body.body.is_playing())
		other.free()
	arena.free()
	print("PASS: four dash directions, three durations, frame/weapon/arm sync, interrupted dash, normal scale and other-class fallback")
	quit()
