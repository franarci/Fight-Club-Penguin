extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var music = root.get_node("Music")
	var home = load("res://src/ui/home/Home.tscn").instantiate()
	root.add_child(home)
	assert(music.menu_player.playing)
	assert(music.active_player == music.menu_player)
	assert(music.menu_player.playback_type == AudioServer.PLAYBACK_TYPE_STREAM)
	assert(music.get_child_count() == 2)
	for child in music.get_children():
		assert(child is AudioStreamPlayer)
	assert(not music.has_method("unlock_audio"))
	var selector = load("res://src/ui/character_selection/PlayerSelection.tscn").instantiate()
	root.add_child(selector)
	assert(not selector.has_node("VBoxContainer/PlayerLabel/ControllerIcons"))
	assert(not selector.has_method("_cycle_controller_icons"))
	assert(not root.has_node("ControllerProfiles"))
	selector.free()
	home.free()
	music.menu_player.stop()
	await create_timer(0.1).timeout
	print("PASS: Home requests immediate music, Stream playback, no startup gate and no manual controller selector")
	quit()
