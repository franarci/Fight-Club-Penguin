extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	for character_name in ["Gunner", "Demolisher", "Hunter", "Scout"]:
		var scene = load("res://src/entities/prototypes/characters/%s.tscn" % character_name).instantiate()
		scene.get_child(0).setup(0, -1)
		root.add_child(scene)
		var penguin = scene.get_child(0)
		penguin.set_physics_process(false)
		if is_instance_valid(penguin.current_weapon):
			penguin.current_weapon.set_process(false)
		var original_scale: Vector2 = penguin.body.scale
		for factor in [0.5, 1.0, 2.0]:
			penguin.body.scale = original_scale * factor
			penguin.update_player_identifier()
			var bounds: Rect2 = penguin.body.transform * penguin.get_body_display_rect()
			var triangle_tip: Vector2 = penguin.player_indicator.position + (penguin.player_arrow.position + Vector2(0, 8)) * penguin.player_indicator.scale
			assert(is_equal_approx(triangle_tip.y, bounds.position.y - penguin.identifier_head_gap))
			assert(is_equal_approx(triangle_tip.x, bounds.get_center().x))
			assert(penguin.player_indicator.global_scale.is_equal_approx(Vector2.ONE))
			assert(penguin.player_label.get_theme_font_size("font_size") == 28)
			assert(penguin.player_label.position.y + penguin.player_label.size.y < penguin.player_arrow.position.y)
		penguin.identifier_offset = Vector2(3, -2)
		penguin.update_player_identifier()
		var reference_scale: Vector2 = penguin.player_indicator.scale
		for animation_name in penguin.body.sprite_frames.get_animation_names():
			if not String(animation_name).begins_with("dash_"):
				continue
			penguin.body.animation = animation_name
			for frame in range(penguin.body.sprite_frames.get_frame_count(animation_name)):
				penguin.body.frame = frame
				penguin.update_player_identifier()
				assert(penguin.player_indicator.scale.is_equal_approx(reference_scale), "Dash frames must not resize the identifier")
				var dash_bounds: Rect2 = penguin.body.transform * penguin.get_body_display_rect()
				assert(is_equal_approx(penguin.player_indicator.position.y, dash_bounds.position.y - penguin.identifier_head_gap + penguin.identifier_offset.y))
		penguin.update_player_identifier()
		var position: Vector2 = penguin.player_indicator.position
		penguin.scale *= 2
		penguin.update_player_identifier()
		assert(penguin.player_indicator.position == position, "Parent scaling must not be applied twice")
		assert(penguin.player_indicator.global_scale.is_equal_approx(Vector2.ONE))
		for slot in range(4):
			penguin.player_index = slot
			penguin.apply_player_identity()
			penguin.update_player_identifier()
			assert(penguin.player_label.text == "P%d" % (slot + 1))
			assert(penguin.player_label.get_theme_font_size("font_size") == 28)
			assert(penguin.player_indicator.global_scale.is_equal_approx(Vector2.ONE))
		penguin.auto_player_identifier = false
		penguin.player_indicator.position = Vector2(123, 456)
		penguin.update_player_identifier()
		assert(penguin.player_indicator.position == Vector2(123, 456))
		scene.free()
	paused = true
	var characters: Array[Node] = []
	for slot in range(4):
		var character = load("res://src/entities/prototypes/characters/%s.tscn" % ["Gunner", "Demolisher", "Hunter", "Scout"][slot]).instantiate()
		character.get_child(0).setup(slot, -1)
		root.add_child(character)
		var initial_penguin = character.get_child(0)
		assert(initial_penguin.player_label.text == "P%d" % (slot + 1))
		assert(initial_penguin.player_label.get_theme_font_size("font_size") == 28)
		assert(initial_penguin.player_indicator.global_scale.is_equal_approx(Vector2.ONE))
		assert(is_zero_approx(initial_penguin.player_label.position.x + initial_penguin.player_label.size.x * 0.5))
		for node in character.find_children("*", "Node", true, false):
			node.set_process(false)
			node.set_physics_process(false)
		characters.append(character)
	paused = false
	for distance in [200.0, 40.0, 10.0, 0.0, -10.0, -40.0, -200.0]:
		for slot in range(4):
			var penguin = characters[slot].get_child(0)
			penguin.global_position = Vector2(distance * slot, 0)
		for character in characters:
			var penguin = character.get_child(0)
			penguin.update_player_identifier()
			var label_center: float = penguin.player_label.position.x + penguin.player_label.size.x * 0.5
			assert(is_zero_approx(label_center), "Nearby players must not shift the identifier sideways")
			assert(penguin.player_indicator.global_scale.is_equal_approx(Vector2.ONE))
	for character in characters:
		character.free()
	print("PASS: equal P1-P4 size, four classes, dash frames, parent scale, centered nearby identifiers, paused countdown initialization and manual override")
	quit()
