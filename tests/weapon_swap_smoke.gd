extends SceneTree

var HAMMER: PackedScene
var RIFLE: PackedScene

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	HAMMER = load("res://src/entities/prototypes/weapons/melee/Hammer.tscn")
	RIFLE = load("res://src/entities/prototypes/weapons/ranged/Rifle.tscn")
	root.get_node("PlayerManager").join_player(-1, 0)
	for character in ["Gunner", "Demolisher"]:
		var scene = load("res://src/entities/prototypes/characters/%s.tscn" % character).instantiate()
		var penguin = scene.get_child(0)
		penguin.setup(0, -1)
		root.add_child(scene)
		current_scene = scene
		penguin.set_physics_process(false)
		penguin.update_facing(Vector2(1, -1))
		assert(penguin.equip_weapon(HAMMER))
		var hammer = penguin.current_weapon
		assert(hammer.has_method("cancel_attack") and hammer.wielder == penguin and hammer.device == -1)
		assert(hammer.direction_8 == Vector2i(1, -1))
		hammer.attack()
		assert(hammer.swing_time_left > 0.0)
		assert(penguin.equip_weapon(RIFLE))
		assert(hammer.swing_time_left == 0.0 and not hammer.is_inside_tree())
		var rifle = penguin.current_weapon
		assert(rifle.has_method("get_muzzle_global_position") and not rifle.can_attack)
		assert(not penguin.equip_weapon(HAMMER, rifle.weapon_data))
		assert(penguin.current_weapon == rifle)
		rifle.attack_cooldown.stop()
		rifle.can_attack = true
		rifle.try_attack()
		assert(scene.get_child(scene.get_child_count() - 1) is Projectile)
		assert(penguin.unequip_weapon())
		assert(penguin.current_weapon == null)
		if character == "Gunner":
			penguin.play_animation(&"dash")
			penguin.advance_dash_animation(penguin.dash_duration)
			penguin.play_animation(&"idle")
		assert(penguin.equip_weapon(RIFLE))
		assert(not penguin.current_weapon.can_attack)
		if character == "Gunner":
			penguin.play_animation(&"dash")
			var previous = penguin.current_weapon
			assert(penguin.equip_weapon(HAMMER))
			assert(penguin.current_weapon == previous and penguin.weapon_change_pending)
			penguin.advance_dash_animation(penguin.dash_duration * 0.5)
			penguin.play_animation(&"idle")
			assert(penguin.current_weapon.has_method("cancel_attack"))
			assert(penguin.current_weapon.name == "EquippedWeapon")
			penguin.play_animation(&"dash")
			assert(penguin.equip_weapon(RIFLE))
		penguin.lose_life()
		assert(not penguin.equip_weapon(RIFLE))
		assert(not penguin.weapon_change_pending)
		assert(penguin.current_weapon.process_mode == Node.PROCESS_MODE_DISABLED)
		penguin.respawn_timer.stop()
		penguin._on_respawn_timer_timeout()
		assert(not penguin.is_dead and penguin.current_weapon.can_attack)
		assert(penguin.equip_weapon(RIFLE))
		scene.free()
	print("PASS: both classes swap melee/ranged weapons; attacks, cooldowns, dash queues, invalid data, death and respawn")
	quit()


