extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("run_checks")


func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		push_error("FAIL: %s" % description)
		failures.append(description)


func run_checks() -> void:
	var penguin_scene: PackedScene = load("res://src/entities/prototypes/penguin/penguin_base.tscn")
	var hunter_frames: SpriteFrames = load("res://src/entities/prototypes/characters/hunter_sprite_frames.tres")
	var attacker = penguin_scene.instantiate()
	var target = penguin_scene.instantiate()
	for penguin in [attacker, target]:
		penguin.p_spriteframes = hunter_frames
		penguin.p_autoplay = "idle_down"
	root.add_child(attacker)
	root.add_child(target)
	attacker.set_physics_process(false)
	target.set_physics_process(false)
	attacker.global_position = Vector2(-100, 0)
	target.global_position = Vector2.ZERO
	await physics_frame

	# This point is outside the 8 px physics capsule, but inside the damage hurtbox.
	var probe_position: Vector2 = target.global_position + Vector2(15, 12)
	var probe_shape := CircleShape2D.new()
	probe_shape.radius = 6.0
	var area_query := PhysicsShapeQueryParameters2D.new()
	area_query.shape = probe_shape
	area_query.transform = Transform2D(0.0, probe_position)
	area_query.collision_mask = 1
	area_query.collide_with_areas = true
	area_query.collide_with_bodies = false
	var area_detected := false
	for result in target.get_world_2d().direct_space_state.intersect_shape(area_query, 8):
		var collider = result.collider
		if collider is Area2D and collider.get_parent() == target:
			area_detected = true
	check(area_detected, "expanded damage hurtbox reaches beyond movement capsule")

	var melee_weapon = load("res://src/entities/prototypes/weapons/melee/MeleeWeapon.tscn").instantiate()
	melee_weapon.set_process(false)
	root.add_child(melee_weapon)
	melee_weapon.wielder = attacker
	var melee_data := MeleeWeaponData.new()
	melee_data.damage = 15.0
	melee_data.hit_radius = 6.0
	melee_weapon.setup(-1, melee_data)
	melee_weapon.attack_shape.radius = 6.0
	melee_weapon.hitbox.global_transform = Transform2D(0.0, probe_position)
	target.set_health(100.0)
	melee_weapon.apply_swing_hits()
	check(is_equal_approx(target.current_health, 85.0), "melee query resolves the hurtbox area to its penguin")

	var harpoon = load("res://src/entities/prototypes/weapons/melee/HarpoonProjectile.tscn").instantiate()
	root.add_child(harpoon)
	harpoon.set_physics_process(false)
	harpoon.wielder = attacker
	harpoon.hit_shape.radius = 6.0
	check(harpoon.find_target(probe_position) == target, "harpoon query detects the expanded hurtbox")

	var bullet = load("res://src/entities/prototypes/projectiles/RifleProjectile.tscn").instantiate()
	root.add_child(bullet)
	bullet.shooter = attacker
	bullet.damage = 7.0
	target.set_health(100.0)
	bullet._handle_hit(target.damage_hitbox)
	check(is_equal_approx(target.current_health, 93.0), "ranged projectile forwards an area hit to its penguin")

	var player_manager = root.get_node("PlayerManager")
	player_manager.clear_players()
	player_manager.join_player(-1, 0)
	player_manager.join_player(0, 1)
	attacker.setup(0, -1)
	target.setup(1, 0)
	target.lose_life()
	await physics_frame
	check(target.damage_hitbox.collision_layer == 0, "death disables the damage hurtbox")
	target.respawn_timer.stop()
	target._on_respawn_timer_timeout()
	await physics_frame
	check(target.damage_hitbox.collision_layer == 1, "respawn restores the damage hurtbox")

	melee_weapon.melee_data = null
	melee_weapon.weapon_data = null
	melee_weapon.free()
	harpoon.free()
	attacker.free()
	target.free()
	if is_instance_valid(bullet):
		bullet.free()
	area_query = null
	probe_shape = null
	melee_data = null
	hunter_frames = null
	await process_frame
	print("PASS: penguin hurtbox smoke checks") if failures.is_empty() else push_error("FAIL: %d hurtbox check(s)" % failures.size())
	quit(0 if failures.is_empty() else 1)
