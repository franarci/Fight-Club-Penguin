extends SceneTree

class Target extends StaticBody2D:
	var hits := 0
	var health := 100.0
	func receive_damage(amount: float, _source: Node2D, _direction: Vector2) -> void:
		hits += 1
		health -= amount

func _initialize() -> void:
	call_deferred("run_checks")

func make_target(at: Vector2) -> Target:
	var target := Target.new()
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 3.0
	collision.shape = shape
	target.add_child(collision)
	root.add_child(target)
	target.position = at
	return target

func ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func run_checks() -> void:
	var attacker := make_target(Vector2.ZERO)
	var target := make_target(Vector2(30, 0))
	var second := make_target(Vector2(30, 5))
	var behind := make_target(Vector2(-30, 0))
	var distant := make_target(Vector2(100, 0))
	var weapon = load("res://src/entities/prototypes/weapons/melee/MeleeWeapon.tscn").instantiate()
	attacker.add_child(weapon)
	weapon.scale = Vector2(0.1, 0.1)
	weapon.set_process(false)
	weapon.wielder = attacker
	var data := MeleeWeaponData.new()
	data.windup_duration = 0
	data.recovery_duration = 0
	data.damage = 17
	data.attack_duration = 0.1
	data.attack_cooldown = 0.1
	weapon.setup(-1, data)
	await ticks(2)
	weapon.try_attack()
	await ticks(3)
	assert(target.hits == 1 and second.hits == 1)
	assert(target.health == 83)
	assert(attacker.hits == 0 and behind.hits == 0 and distant.hits == 0)
	weapon.try_attack()
	await ticks(5)
	assert(target.hits == 1)
	assert(not weapon.can_attack)
	await create_timer(0.15).timeout
	assert(weapon.can_attack)
	second.free()
	behind.free()
	distant.free()
	for i in range(8):
		var direction := Vector2.RIGHT.rotated(i * PI / 4.0)
		target.position = direction * data.attack_range
		weapon.set_aim_direction(direction)
		await ticks(2)
		var previous := target.hits
		weapon.try_attack()
		await ticks(3)
		assert(target.hits == previous + 1, "Direction %d missed" % i)
		assert(weapon.hitbox.global_scale.is_equal_approx(Vector2.ONE))
		await create_timer(0.25).timeout
	# A cancelled swing cannot resume and damage after respawn.
	weapon.try_attack()
	weapon.cancel_attack()
	var previous := target.hits
	await ticks(3)
	assert(target.hits == previous)
	attacker.free()
	target.free()
	print("PASS: melee damage, multiple opponents once per swing, self exclusion, reach, cooldown, eight directions, visual-scale independence and cancellation")
	quit()
