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
		assert(Rect2(camera.screen_padding, viewport_size - camera.screen_padding * 2.0).grow(0.01).has_point(screen))
	var distant_zoom: float = camera.zoom.x
	camera.frame_points(near_points, 0.016)
	assert(camera.zoom.x > distant_zoom and camera.zoom.x < close)
	var boundary: CollisionPolygon2D = main.get_node("Arena/IceArea/CollisionPolygon2D")
	for spawn in main.get_node("SpawnPoints").get_children():
		assert(Geometry2D.is_point_in_polygon(boundary.to_local(spawn.global_position + Vector2(0, 17)), boundary.polygon))
	assert(main.character_select.get_parent() is CanvasLayer)
	main.free()
	print("PASS: shared camera close-up, immediate wide framing, smooth zoom-in, enlarged arena spawns, and fixed menu layer")
	quit()
