extends Node


func _ready() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	PlayerManager.clear_players()
	var main: Node = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(main)
	get_tree().current_scene = main

	var selection = main.get_node("MenuLayer/CharacterSelect")
	selection.activate_player_slot(-1)
	var scout_card: PlayerSelection = selection.player_slots[0]
	scout_card.next()
	scout_card.next()
	assert(scout_card.player_label.text == "Scout")
	assert(not scout_card.select_button.disabled)
	assert(scout_card.character.texture.resource_path == "res://assets/textures/character_select/explorer.webp")
	assert((scout_card.character.material as ShaderMaterial).get_shader_parameter("saturation") == 1.0)
	scout_card.confirm_character()
	assert(PlayerManager.get_player_by_device(-1).character.key == "Scout")

	selection.activate_player_slot(0)
	var second_card: PlayerSelection = selection.player_slots[1]
	assert(second_card.player_label.text == "Gunner")
	second_card.confirm_character()
	selection._open_ready_dialog()
	selection.finish_character_selection()

	assert(main.players.get_child_count() == 2)
	assert(main.players.get_child(0).name == "Scout")
	assert(main.players.get_child(1).name == "Gunner")
	var scout: Penguin = main.players.get_child(0).get_child(0) as Penguin
	assert(scout.player_initialized)
	assert(scout.current_weapon is RangedWeapon)
	assert((scout.current_weapon as RangedWeapon).ranged_data.weapon_name == "ScoutRifle")
	assert((scout.current_weapon as RangedWeapon).ranged_data.magazine_capacity == 1)
	var scout_hud: PlayerLivesCard = main.get_node("ArenaHUD").cards[0]
	assert(scout_hud.title.text == "SCOUT")
	assert(scout_hud.portrait.texture.resource_path == "res://assets/textures/character_select/explorer.webp")
	assert(scout_hud.weapon_status.visible)
	assert(scout_hud.ammo_pips.capacity == 1)

	get_tree().paused = false
	main.free()
	PlayerManager.clear_players()
	print("PASS: color Explorer presentation card selects Scout and the match spawns Scout with ScoutRifle")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
