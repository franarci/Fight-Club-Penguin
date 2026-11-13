extends Node

func _ready() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var classes := ["Gunner", "Demolisher", "Hunter", "Scout"]
	var directions := [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP, Vector2(1, 1).normalized(), Vector2(-1, 1).normalized(), Vector2(1, -1).normalized(), Vector2(-1, -1).normalized()]
	var checks := 0
	for first_index in range(classes.size()):
		for second_index in range(first_index, classes.size()):
			var first = load("res://src/entities/prototypes/characters/%s.tscn" % classes[first_index]).instantiate()
			var second = load("res://src/entities/prototypes/characters/%s.tscn" % classes[second_index]).instantiate()
			add_child(first)
			add_child(second)
			for character in [first, second]:
				for node in character.find_children("*", "Node", true, false):
					node.set_process(false)
					node.set_physics_process(false)
			var a: Penguin = first.get_child(0)
			var b: Penguin = second.get_child(0)
			for penguin in [a, b]:
				penguin.set_physics_process(false)
				penguin.protection_left = 0.0
			var ac: CollisionShape2D = a.get_node("Collision")
			var bc: CollisionShape2D = b.get_node("Collision")
			var a_bounds: Rect2 = ac.global_transform * ac.shape.get_rect()
			var b_bounds: Rect2 = bc.global_transform * bc.shape.get_rect()
			assert(a_bounds.size.x >= 44 and a_bounds.size.y >= 29)
			assert(b_bounds.size.x >= 44 and b_bounds.size.y >= 29)
			var a_offset := ac.global_position - a.global_position
			var b_offset := bc.global_position - b.global_position
			for direction in directions:
				for speed in [180.0, 600.0]:
					var extent: Vector2 = (a_bounds.size + b_bounds.size) * 0.5
					var separation: float = absf(direction.x) * extent.x + absf(direction.y) * extent.y + 10.0
					a.global_position = Vector2(-5000, -5000) - a_offset
					b.global_position = Vector2(-5000, -5000) + direction * separation - b_offset
					a.velocity = Vector2.ZERO
					b.velocity = Vector2.ZERO
					b.is_being_pushed = false
					await get_tree().physics_frame
					var touched := false
					var health := b.current_health
					for step in range(12):
						a.velocity = direction * speed
						a.move_and_slide()
						if a.get_slide_collision_count() > 0:
							touched = true
							if speed == 600.0:
								a.dash_direction = direction
								a.check_dash_impact()
								assert(b.is_being_pushed)
							else:
								a.check_contact_push(direction * speed, 1.0 / 60.0)
						b.move_and_slide()
						assert(not ac.shape.collide(ac.global_transform, bc.shape, bc.global_transform), "%s/%s overlap in %s" % [classes[first_index], classes[second_index], direction])
						assert((bc.global_position - ac.global_position).dot(direction) > 0.0)
						await get_tree().physics_frame
					assert(touched, "%s/%s did not contact in %s" % [classes[first_index], classes[second_index], direction])
					assert(b.current_health == health)
					checks += 1
			first.free()
			second.free()
	print("PASS: %d contacts across four classes, eight directions, normal movement and dash, without penetration or contact damage" % checks)
	get_tree().quit()
