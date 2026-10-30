extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	current_scene = arena
	var characters: Array[Node] = []
	for name in ["Demolisher", "Gunner"]:
		var scene = load("res://src/entities/prototypes/characters/%s.tscn" % name).instantiate()
		scene.get_child(0).setup(characters.size(), -1)
		arena.add_child(scene)
		var penguin = scene.get_child(0)
		penguin.set_physics_process(false)
		penguin.current_weapon.set_process(false)
		penguin.current_weapon.set_physics_process(false)
		characters.append(penguin)
	var heavy = characters[0]
	var light = characters[1]
	var hammer = heavy.current_weapon
	var rifle = light.current_weapon
	heavy.mass = 1.25
	heavy.melee_power = 1.2
	heavy.ranged_attack_speed = 0.9
	heavy.ranged_handling = 0.9
	light.mass = 0.8
	light.melee_power = 0.85
	light.ranged_attack_speed = 1.15
	light.ranged_handling = 1.15
	var hammer_damage: float = hammer.melee_data.damage
	var rifle_damage: float = rifle.ranged_data.damage
	var cooldown: float = rifle.ranged_data.attack_cooldown
	rifle.ranged_data = rifle.ranged_data.duplicate()
	rifle.ranged_data.spread = 0.2
	for user in characters:
		# The same weapon resources use whichever penguin currently wields them.
		hammer.wielder = user
		rifle.wielder = user
		assert(is_equal_approx(hammer.get_effective_damage(), hammer_damage * user.melee_power))
		assert(is_equal_approx(rifle.get_attack_cooldown(), cooldown / user.ranged_attack_speed))
		assert(is_equal_approx(rifle.get_effective_spread(), 0.2 / user.ranged_handling))
		user.receive_push(Vector2.RIGHT, 150)
		assert(is_equal_approx(user.velocity.x, 150 / user.mass))
		user.receive_damage(10)
		assert(user.current_health == 90, "Mass must not provide damage resistance")
		rifle.attack()
		assert(is_equal_approx(rifle.attack_cooldown.wait_time, cooldown / user.ranged_attack_speed))
	for child in arena.get_children():
		if child is Projectile:
			assert(child.damage == rifle_damage, "Character stats must not amplify bullet damage")
	assert(hammer.melee_data.damage == hammer_damage)
	assert(rifle.weapon_data.attack_cooldown == cooldown)
	light.mass = 0
	light.receive_push(Vector2.RIGHT, 150)
	assert(is_finite(light.velocity.x))
	arena.free()
	print("PASS: interchangeable wielders, melee power, mass resistance, ranged cadence/accuracy, unchanged bullet damage and shared weapon data")
	quit()
