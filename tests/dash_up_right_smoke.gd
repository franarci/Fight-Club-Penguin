extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var character = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	root.add_child(character)
	var penguin = character.get_child(0)
	penguin.set_physics_process(false)
	penguin.update_facing(Vector2(1, -1))
	penguin.play_animation(&"dash")
	assert(penguin.animation_player.current_animation == &"dash_up_right")
	assert(penguin.body.animation == &"dash_up_left" and penguin.body.flip_h)
	assert(penguin.weapon_socket.position == Vector2(0, 4))
	penguin.advance_dash_animation(penguin.dash_duration * 0.5)
	assert(penguin.body.frame == 2)
	penguin.play_animation(&"idle")
	assert(penguin.weapon_socket.position == penguin.standing_weapon_position)
	character.free()
	print("PASS: up-right timeline selected, mirrored artwork, dash position and restoration")
	quit()
