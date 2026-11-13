extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	root.size = Vector2i(1152, 648)
	var main = load("res://Main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	var camera = main.get_node("SharedCamera")
	var container: Node2D = main.get_node("Players")
	camera.players = container
	var near_points: Array[Vector2] = [Vector2(800, 500), Vector2(850, 520)]
	camera.frame_points(near_points, 0.0, true)
	var close: float = camera.zoom.x
	assert(is_equal_approx(close, camera.close_zoom))
	var far_points: Array[Vector2] = [Vector2(200, 200), Vector2(1600, 850)]
	camera.frame_points(far_points, 0.016)
	assert(camera.zoom.x < close)
	var viewport_size := root.get_visible_rect().size
	for point in far_points:
		var screen: Vector2 = (point - camera.global_position) * camera.zoom + viewport_size / 2.0
		assert(Rect2(Vector2.ZERO, viewport_size).has_point(screen))
	var distant_zoom: float = camera.zoom.x
	camera.frame_points(near_points, 0.016)
	assert(is_equal_approx(camera.zoom.x, distant_zoom))
	for index in range(120):
		camera.frame_points(near_points, 1.0 / 60.0)
	assert(camera.zoom.x > distant_zoom and camera.zoom.x < close)
	var boundary: CollisionPolygon2D = main.get_node("Arena/IceArea/Ground")
	for spawn in main.get_node("SpawnPoints").get_children():
		assert(Geometry2D.is_point_in_polygon(boundary.to_local(spawn.global_position + Vector2(0, 17)), boundary.polygon))
	assert(main.character_select.get_parent() is CanvasLayer)
	for dimensions in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(800, 600), Vector2i(1440, 900)]:
		root.size = dimensions
		await process_frame
		await process_frame
		for corner in [Vector2.ZERO, camera.arena_size, Vector2(camera.arena_size.x, 0), Vector2(0, camera.arena_size.y)]:
			var corners: Array[Vector2] = [corner]
			camera.frame_points(corners, 0.0, true)
			camera.request_shake(20, 0.2)
			camera._update_shake(0.016)
			camera._clamp_view_to_arena()
			var half_view: Vector2 = camera.get_viewport_rect().size / (camera.zoom * 2.0)
			var visible_area := Rect2(camera.global_position + camera.offset - half_view, half_view * 2.0)
			var ocean: ColorRect = main.get_node("Arena/OceanBackdrop")
			var ocean_bounds: Rect2 = ocean.get_global_transform() * Rect2(Vector2.ZERO, ocean.size)
			assert(ocean_bounds.grow(0.01).encloses(visible_area))
	main.free()
	print("PASS: shared camera framing safety, zoom-in delay, gradual return, arena spawns and fixed menu layer")
	quit()
