extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run_checks")

func check_animation(penguin: Node, direction: Vector2, state: StringName, expected: StringName, mirrored: bool) -> void:
	penguin.update_facing(direction)
	penguin.play_animation(state)
	if penguin.body.animation != expected or penguin.body.flip_h != mirrored:
		push_error("Expected %s (mirrored=%s), got %s (mirrored=%s)" % [expected, mirrored, penguin.body.animation, penguin.body.flip_h])
		failures += 1

func run_checks() -> void:
	for character_name in ["Demolisher", "Gunner"]:
		var character = load("res://src/entities/prototypes/characters/%s.tscn" % character_name).instantiate()
		root.add_child(character)
		var penguin = character.get_child(0)
		penguin.set_physics_process(false)
		if character_name == "Demolisher":
			check_animation(penguin, Vector2(-1, -1), &"walk", &"walk_up_right", true)
			check_animation(penguin, Vector2(1, -1), &"walk", &"walk_up_right", false)
			check_animation(penguin, Vector2(-1, 1), &"walk", &"walk_down_right", true)
			check_animation(penguin, Vector2(1, 1), &"walk", &"walk_down_right", false)
			check_animation(penguin, Vector2(-1, -1), &"idle", &"idle_up", false)
			check_animation(penguin, Vector2(-1, 1), &"dash", &"dash_down_right", true)
		else:
			check_animation(penguin, Vector2(1, -1), &"walk", &"walk_up_left", true)
			check_animation(penguin, Vector2(-1, -1), &"walk", &"walk_up_left", false)
			check_animation(penguin, Vector2(-1, 1), &"walk", &"walk_down", false)
			check_animation(penguin, Vector2(1, 1), &"walk", &"walk_down", false)
			check_animation(penguin, Vector2(1, -1), &"dash", &"dash_up", false)
		check_animation(penguin, Vector2.LEFT, &"walk", &"walk_left", true)
		check_animation(penguin, Vector2.UP, &"walk", &"walk_up", false)
		check_animation(penguin, Vector2(1, 0.1), &"walk", &"walk_right", false)
		character.free()
	if failures == 0:
		print("PASS: diagonal animations, mirrored artwork, empty-animation fallback, idle/dash fallback, flip reset and analog sectors")
	quit(1 if failures else 0)
