extends Node

const MENU_TRACK := "res://assets/audio/music/menu_icebreaker.wav"
const COMBAT_TRACK := "res://assets/audio/music/combat_icebreaker.wav"
const CROSSFADE_SECONDS := 0.45

var menu_player: AudioStreamPlayer
var combat_player: AudioStreamPlayer
var active_player: AudioStreamPlayer
var transition: Tween
var _orca_attack_gain := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_player = _create_player(MENU_TRACK, "MenuMusic")
	combat_player = _create_player(COMBAT_TRACK, "CombatMusic")


func _create_player(track_path: String, player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = &"Music"
	player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	player.stream = load(track_path) as AudioStreamWAV
	player.volume_linear = 0.0
	add_child(player)
	return player


func play_menu() -> void:
	_play(menu_player)


func play_combat() -> void:
	_play(combat_player)


func set_orca_attack_ducked(ducked: bool, attenuation_db: float = -12.0, fade_seconds: float = 0.25) -> void:
	_orca_attack_gain = db_to_linear(attenuation_db) if ducked else 1.0
	if transition != null:
		transition.kill()
	var fade_time := maxf(fade_seconds, 0.0)
	if fade_time <= 0.001:
		for player in [menu_player, combat_player]:
			if is_instance_valid(player) and player.playing:
				player.volume_linear = _orca_attack_gain if player == active_player else 0.0
		transition = null
		return
	transition = create_tween().set_parallel(true)
	for player in [menu_player, combat_player]:
		if is_instance_valid(player) and player.playing:
			var target_gain := _orca_attack_gain if player == active_player else 0.0
			transition.tween_property(player, "volume_linear", target_gain, fade_time)


func _play(player: AudioStreamPlayer) -> void:
	if active_player == player and player.playing:
		return
	if transition != null:
		transition.kill()
	var outgoing := active_player
	active_player = player
	if not player.playing:
		player.volume_linear = 0.0
		player.play()
	transition = create_tween().set_parallel(true)
	transition.tween_property(player, "volume_linear", _orca_attack_gain, CROSSFADE_SECONDS)
	if outgoing != null and outgoing != player:
		transition.tween_property(outgoing, "volume_linear", 0.0, CROSSFADE_SECONDS)
		transition.chain().tween_callback(outgoing.stop)


func _exit_tree() -> void:
	if transition != null:
		transition.kill()
	for player in [menu_player, combat_player]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
