extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var music = root.get_node("Music")
	var music_bus := AudioServer.get_bus_index("Music")
	var fx_bus := AudioServer.get_bus_index("FX")
	assert(music_bus > 0 and fx_bus > 0 and music_bus != fx_bus)
	AudioServer.set_bus_mute(music_bus, true)
	assert(not AudioServer.is_bus_mute(fx_bus))
	AudioServer.set_bus_mute(music_bus, false)
	for player in [music.menu_player, music.combat_player]:
		var stream := player.stream as AudioStreamWAV
		assert(stream != null and stream.stereo and stream.mix_rate == 32000)
		assert(stream.format == AudioStreamWAV.FORMAT_16_BITS)
		assert(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD)
		assert(stream.loop_begin == 0)
		assert(stream.loop_end == stream.data.size() / 4 - 1)
		assert(stream.get_length() > 44.0 and stream.get_length() < 45.0)
		assert(player.bus == &"Music")
	music.play_menu()
	var first_transition: Tween = music.transition
	music.play_menu()
	assert(music.transition == first_transition)
	await create_timer(0.6).timeout
	assert(music.menu_player.playing and not music.combat_player.playing)
	music.play_combat()
	assert(music.menu_player.playing and music.combat_player.playing)
	await create_timer(0.6).timeout
	assert(music.combat_player.playing and not music.menu_player.playing)
	paused = true
	await create_timer(0.1).timeout
	assert(music.combat_player.playing and not music.combat_player.stream_paused)
	paused = false
	music.play_menu()
	await create_timer(0.1).timeout
	music.play_combat()
	await create_timer(0.6).timeout
	assert(music.combat_player.playing and not music.menu_player.playing)
	assert(is_zero_approx(music.combat_player.volume_db))
	assert(music.get_child_count() == 2)
	music.menu_player.stop()
	music.combat_player.stop()
	await create_timer(0.1).timeout
	print("PASS: stereo PCM loops, separate buses, persistent menu, crossfades, interrupted transitions and music during pause")
	quit()
