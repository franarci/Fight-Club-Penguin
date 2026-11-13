extends Node


func _ready() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var manager = get_tree().root.get_node("PlayerManager")
	manager.clear_players()
	var character_keys := ["Gunner", "Demolisher", "Scout"]
	var character_scenes := [
		preload("res://src/entities/prototypes/characters/Gunner.tscn"),
		preload("res://src/entities/prototypes/characters/Demolisher.tscn"),
		preload("res://src/entities/prototypes/characters/Scout.tscn"),
	]
	for slot in character_keys.size():
		assert(manager.join_player(slot - 1, slot))
		var data := CharacterData.new()
		data.key = character_keys[slot]
		data.character_scene = character_scenes[slot]
		manager.players[slot]["character"] = data
		manager.players[slot]["ready"] = true
	var main = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	var selection = main.get_node("MenuLayer/CharacterSelect")
	assert(selection.selection_finished.is_connected(main.prepare_match))
	selection._open_ready_dialog()
	selection.finish_character_selection()
	assert(main.players.get_child_count() == character_keys.size())
	assert(selection.is_queued_for_deletion())
	assert(main.pre_match.active and get_tree().paused)
	for index in character_keys.size():
		var character: Node = main.players.get_child(index)
		assert(character.name == character_keys[index])
		assert(character.get_child(0).player_initialized)
	var scout: Penguin = main.players.get_child(2).get_child(0) as Penguin
	assert(scout.current_weapon is RangedWeapon)
	assert((scout.current_weapon as RangedWeapon).ranged_data.weapon_name == "ScoutRifle")
	assert((scout.current_weapon as RangedWeapon).ranged_data.magazine_capacity == 1)
	await get_tree().process_frame
	assert(not main.has_node("MenuLayer/CharacterSelect"))
	get_tree().paused = false
	main.free()
	manager.clear_players()
	print("PASS: ready confirmation spawns Gunner, Demolisher and Scout from their selected scenes; Scout has its single-shot rifle")
	get_tree().quit()
