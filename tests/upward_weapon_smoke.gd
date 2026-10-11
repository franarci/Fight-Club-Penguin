extends SceneTree

func _initialize() -> void:
	call_deferred("check_upward")

func check_upward() -> void:
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var character = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	var penguin = character.get_child(0)
	penguin.setup(0,-1)
	main.get_node("Players").add_child(character)
	var weapon = penguin.current_weapon
	var base_position = weapon.position
	for direction in [Vector2.UP, Vector2(-1,-1), Vector2(1,-1)]:
		penguin.update_facing(direction)
		penguin.play_animation(&"walk")
		assert(main.get_node("Ground").z_index < weapon.z_index)
		assert(weapon.z_index < penguin.body.z_index)
		assert(weapon.position == base_position)
		var gun_image = weapon.body.sprite_frames.get_frame_texture(weapon.body.animation,0).get_image()
		var body_image = penguin.body.sprite_frames.get_frame_texture(penguin.body.animation,0).get_image()
		var exposed := 0
		for y in range(0, gun_image.get_height(), 4):
			for x in range(0, gun_image.get_width(), 4):
				if gun_image.get_pixel(x,y).a < 0.5:
					continue
				var point := Vector2(x,y) - Vector2(gun_image.get_size()) / 2.0
				if weapon.body.flip_h:
					point.x = -point.x
				var body_point = penguin.body.to_local(weapon.body.to_global(point)) + Vector2(body_image.get_size()) / 2.0
				if not Rect2(Vector2.ZERO, Vector2(body_image.get_size())).has_point(body_point) or body_image.get_pixel(int(body_point.x),int(body_point.y)).a < 0.5:
					exposed += 1
		assert(exposed > 0)
		print("Visible weapon samples for ", direction, ": ", exposed)
	main.free()
	print("PASS: upward weapons behind body, above ground, with exposed artwork")
	quit()
