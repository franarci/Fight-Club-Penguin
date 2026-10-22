extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	for character_name in ["Gunner", "Demolisher", "Hunter", "Explorer"]:
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
			var label_width: float = penguin.player_label.size.x * penguin.player_indicator.scale.x
			assert(is_equal_approx(label_width, bounds.size.x * penguin.identifier_width_ratio))
			assert(penguin.player_label.position.y + penguin.player_label.size.y < penguin.player_arrow.position.y)
		penguin.identifier_offset = Vector2(3, -2)
		penguin.update_player_identifier()
		var position: Vector2 = penguin.player_indicator.position
		penguin.scale *= 2
		penguin.update_player_identifier()
		assert(penguin.player_indicator.position == position, "Parent scaling must not be applied twice")
		penguin.auto_player_identifier = false
		penguin.player_indicator.position = Vector2(123, 456)
		penguin.update_player_identifier()
		assert(penguin.player_indicator.position == Vector2(123, 456))
		scene.free()
	print("PASS: identifier layout for four classes, body sizes, parent scale, spacing and manual override")
	quit()
