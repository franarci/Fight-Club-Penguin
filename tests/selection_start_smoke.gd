extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	for slot in range(2):
		assert(manager.join_player(slot - 1, slot))
		var data := CharacterData.new()
		data.key = "Gunner" if slot == 0 else "Demolisher"
		manager.players[slot]["character"] = data
		manager.players[slot]["ready"] = true
	var main = load("res://Main.tscn").instantiate()
	main.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(main)
	current_scene = main
	var selection = main.get_node("MenuLayer/CharacterSelect")
	assert(selection.selection_finished.is_connected(main.prepare_match))
	selection._open_ready_dialog()
	selection.finish_character_selection()
	assert(main.players.get_child_count() == 2)
	assert(selection.is_queued_for_deletion())
	assert(main.pre_match.active and paused)
	for character in main.players.get_children():
		assert(character.get_child(0).player_initialized)
	await process_frame
	assert(not main.has_node("MenuLayer/CharacterSelect"))
	paused = false
	main.free()
	manager.clear_players()
	print("PASS: ready confirmation starts Main, spawns both characters under the fixed menu layer and opens the tutorial")
	quit()
