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
	for reset in [false, true]:
		if reset:
			penguin.animation_player.play("RESET")
			penguin.animation_player.advance(0)
			penguin.animation_player.stop()
		penguin.update_facing(Vector2(-1, -1))
		assert(penguin.weapon_socket.z_index == 0)
		assert(penguin.weapon_socket.z_index + penguin.current_weapon.z_index + penguin.current_weapon.body.z_index < penguin.body.z_index)
	scene.free()
	print("PASS: rifle behind body on first up-left turn and after RESET")
	quit()
