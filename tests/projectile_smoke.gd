extends SceneTree

class Target extends StaticBody2D:
	var hits := 0
	var received_damage := 0.0
	var received_source: Node2D
	func receive_damage(amount: float, source: Node2D, _direction: Vector2) -> void:
		hits += 1
		received_damage = amount
		received_source = source

func make_target(at: Vector2) -> Target:
	var target := Target.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(2, 20)
	shape.shape = rectangle
	target.add_child(shape)
	target.position = at
	current_scene.add_child(target)
	return target

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var scene = load("res://src/entities/prototypes/projectiles/RifleProjectile.tscn")
	var shooter := make_target(Vector2(20,100))
	var target := make_target(Vector2(100,100))
	await physics_frame
	await physics_frame
	var bullet = scene.instantiate()
	bullet.initialize(arena, Vector2(20,100), Vector2(8,0), shooter, 1000.0, 23.0)
	bullet.set_physics_process(false)
	assert(bullet.direction == Vector2.RIGHT)
	bullet._handle_hit(shooter)
	assert(not bullet.is_queued_for_deletion() and shooter.hits == 0)
	bullet._physics_process(0.2)
	assert(target.hits == 1 and target.received_damage == 23.0)
	assert(target.received_source == shooter)
	bullet._handle_hit(target)
	assert(target.hits == 1)
	await process_frame
	assert(not is_instance_valid(bullet))
	var expired = scene.instantiate()
	expired.lifetime = 0.05
	expired.remove_offscreen = false
	expired.initialize(arena, Vector2(40,200), Vector2.RIGHT)
	await create_timer(0.15).timeout
	assert(not is_instance_valid(expired))
	var zero = scene.instantiate()
	zero.initialize(arena, Vector2.ZERO, Vector2.ZERO)
	assert(zero.is_queued_for_deletion())
	var offscreen = scene.instantiate()
	offscreen.initialize(arena, Vector2(-1000,-1000), Vector2.LEFT)
	offscreen._physics_process(0.01)
	assert(offscreen.is_queued_for_deletion())
	var original_canvas := root.canvas_transform
	root.canvas_transform = Transform2D(0, Vector2(-10000, 0))
	var on_camera = scene.instantiate()
	on_camera.initialize(arena, Vector2(10040,200), Vector2.RIGHT)
	on_camera._physics_process(0.01)
	assert(not on_camera.is_queued_for_deletion())
	root.canvas_transform = original_canvas
	on_camera.queue_free()
	await process_frame
	arena.free()
	print("PASS: normalized aim, swept hits, shooter exclusion, one hit, damage payload, lifetime, offscreen and canvas transform")
	quit()
