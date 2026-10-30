extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	assert(manager.join_player(-1, 0))
	assert(manager.join_player(0, 1))
	var input_manager = root.get_node("MultiplayerInput")
	input_manager.device_actions[0] = {}
	for action in input_manager.core_actions:
		input_manager.device_actions[0][action] = action
	var gunner = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
	var demolisher = load("res://src/entities/prototypes/characters/Demolisher.tscn").instantiate()
	gunner.get_child(0).setup(0, -1)
	demolisher.get_child(0).setup(1, 0)
	root.add_child(gunner)
	root.add_child(demolisher)
	var target = gunner.get_child(0)
	var other = demolisher.get_child(0)
	for penguin in [target, other]:
		penguin.set_physics_process(false)
		penguin.current_weapon.set_process(false)
	var feedback: DamageFeedback = target.damage_feedback
	var initial_rotation: float = target.body.rotation
	var original_transform: Transform2D = target.global_transform
	var collision: CollisionShape2D = target.get_node("Collision")
	var collision_transform := collision.global_transform
	var palette_color: Color = target.player_palette_instance.get_shader_parameter("player_color")
	target.velocity = Vector2(15, -25)
	assert(not target.receive_damage(0))
	assert(not target.receive_damage(-5))
	assert(not target.receive_damage(5, target))
	target.protection_left = 1.0
	assert(not target.receive_damage(5, other))
	assert(not feedback.active)
	target.protection_left = 0.0
	target.body.self_modulate.a = 0.5
	assert(target.receive_damage(7, other, Vector2.RIGHT))
	assert(target.current_health == 93.0 and feedback.active)
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == 1.0)
	assert(other.player_palette_instance.get_shader_parameter("damage_flash") == 0.0)
	await create_timer(0.065).timeout
	assert(target.body.rotation > initial_rotation)
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") < 1.0)
	assert(target.global_transform == original_transform and collision.global_transform == collision_transform)
	assert(target.velocity == Vector2(15, -25))
	assert(target.body.self_modulate.a == 0.5)
	paused = true
	var paused_rotation: float = target.body.rotation
	var paused_flash: float = target.player_palette_instance.get_shader_parameter("damage_flash")
	await create_timer(0.15).timeout
	assert(target.body.rotation == paused_rotation)
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == paused_flash)
	paused = false
	for i in range(5):
		assert(target.receive_damage(1, other, Vector2.LEFT))
		assert(is_equal_approx(target.body.rotation, initial_rotation))
		await create_timer(0.045).timeout
		assert(target.body.rotation < initial_rotation)
	await create_timer(0.3).timeout
	assert(not feedback.active)
	assert(is_equal_approx(target.body.rotation, initial_rotation))
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == 0.0)
	assert(target.player_palette_instance.get_shader_parameter("player_color") == palette_color)
	assert(target.body.self_modulate.a == 0.5)
	other.global_position = target.global_position + Vector2.RIGHT * 100
	assert(target.receive_damage(1, other))
	await create_timer(0.045).timeout
	assert(target.body.rotation < initial_rotation)
	target.respawn_delay = 10
	assert(target.receive_damage(1000, other, Vector2.RIGHT))
	assert(target.is_dead and not feedback.active and not target.visible)
	assert(is_equal_approx(target.body.rotation, initial_rotation))
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == 0.0)
	target.respawn_timer.stop()
	target._on_respawn_timer_timeout()
	assert(not target.is_dead and target.visible and not feedback.active)
	assert(not target.receive_damage(10, other))
	assert(not feedback.active)
	other.protection_left = 0
	assert(other.receive_damage(1, target, Vector2.RIGHT))
	await create_timer(0.065).timeout
	assert(other.damage_feedback.active and other.body.rotation > 0.0)
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == 0.0)
	await create_timer(0.3).timeout
	assert(not other.damage_feedback.active and is_zero_approx(other.body.rotation))
	gunner.free()
	demolisher.free()
	manager.clear_players()
	print("PASS: accepted damage feedback, independent palettes, repeated hits, direction, pause, unchanged physics/alpha and clean respawn")
	quit()
