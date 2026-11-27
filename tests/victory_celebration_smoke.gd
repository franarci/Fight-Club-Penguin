extends Node

const Celebration = preload("res://src/ui/results/victory_celebration.gd")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run_checks")

func run_checks() -> void:
	var positions: Dictionary = {}
	for kind in ["Gunner", "Demolisher", "Hunter", "Scout"]:
		var character = load("res://src/entities/prototypes/characters/%s.tscn" % kind).instantiate()
		add_child(character)
		var penguin: Penguin = character.get_child(0)
		penguin.current_weapon = penguin.weapon_socket.get_node("EquippedWeapon") as WeaponBase
		penguin.current_weapon.wielder = penguin
		penguin.current_weapon.setup(-1, penguin.starting_weapon_data)
		penguin.update_facing(Vector2.RIGHT)
		penguin.play_animation(&"idle")
		for node in character.find_children("*", "Node", true, false):
			node.set_process(false)
			node.set_physics_process(false)
		var original_body: Vector2 = penguin.body.position
		var original_weapon: Vector2 = penguin.weapon_socket.position
		var original_arm: Vector2 = penguin.arm.position if is_instance_valid(penguin.arm) else Vector2.ZERO
		var original_rotation: float = penguin.weapon_socket.rotation
		var original_body_mode: int = penguin.body.process_mode
		var physics_position := penguin.global_position
		var health: float = penguin.current_health
		var animation = Celebration.new()
		add_child(animation)
		get_tree().paused = true
		animation.start(penguin, StringName(kind))
		animation.set_process(false)
		animation._process(0.25)
		assert(penguin.body.global_position.y < penguin.to_global(original_body).y)
		assert(penguin.global_position == physics_position and penguin.current_health == health)
		assert(penguin.body.process_mode == Node.PROCESS_MODE_ALWAYS)
		var body_offset: Vector2 = penguin.body.position - original_body
		assert((penguin.weapon_socket.position - original_weapon).is_equal_approx(body_offset))
		assert(is_equal_approx(penguin.weapon_socket.rotation, original_rotation))
		if is_instance_valid(penguin.arm):
			assert((penguin.arm.position - original_arm).is_equal_approx(body_offset))
		positions[kind] = body_offset
		animation._process(0.7)
		assert(is_equal_approx(penguin.weapon_socket.rotation, original_rotation))
		assert((penguin.weapon_socket.position - original_weapon).is_equal_approx(penguin.body.position - original_body))
		if kind == "Demolisher":
			assert(animation.puffs.size() == 1)
			await get_tree().create_timer(0.7).timeout
			assert(not is_instance_valid(animation.puffs[0]))
		animation.stop()
		assert(penguin.body.position == original_body)
		assert(penguin.weapon_socket.position == original_weapon)
		assert(penguin.weapon_socket.rotation == original_rotation)
		assert(penguin.body.process_mode == original_body_mode)
		assert(penguin.global_position == physics_position and penguin.current_health == health)
		animation.free()
		character.free()
	assert(positions["Scout"].x != 0 and positions["Gunner"].x == 0)
	assert(positions["Demolisher"].y < positions["Gunner"].y)
	get_tree().paused = false
	print("PASS: four jumping celebrations while paused, synchronized body/weapon/flipper, unchanged weapon angle, Scout side hops, Demolisher snow cleanup, unchanged physics/health and restored poses")
	get_tree().quit()
