extends Node

const PLAYER_DEPTH_Z_PER_PIXEL := 3.0
const PLAYER_DEPTH_Z_LIMIT := 4090

@onready var character_select = $MenuLayer/CharacterSelect
@onready var players: Node2D = $Players
@onready var round_result = $RoundResult
@onready var pause_menu = $PauseMenu
@onready var gamepad_recovery = $GamepadRecovery
@onready var pre_match = $PreMatch
@onready var match_clock = $ArenaHUD/MatchClock

var round_started := false
var round_finished := false
@onready var spawn_1: Marker2D = $SpawnPoints/Spawn1
@onready var spawn_2: Marker2D = $SpawnPoints/Spawn2
@onready var spawn_3: Marker2D = $SpawnPoints/Spawn3
@onready var spawn_4: Marker2D = $SpawnPoints/Spawn4

@onready var spawn_points := [
	spawn_1,
	spawn_2,
	spawn_3,
	spawn_4
]
func _ready() -> void:
	Music.play_menu()
	$SharedCamera.show_arena($Arena.world_size, $Arena.background_margin)
	pre_match.completed.connect(_on_tutorial_completed)
	match_clock.expired.connect(_on_time_limit_reached, CONNECT_DEFERRED)
	round_result.replay_requested.connect(_replay_round)
	round_result.menu_requested.connect(_return_to_menu)
	pause_menu.resume_requested.connect(_resume_round)
	pause_menu.menu_requested.connect(_return_to_menu)
	pause_menu.recovery_slot_requested.connect(gamepad_recovery.choose_slot)
	gamepad_recovery.recovery_changed.connect(_on_recovery_changed)
	gamepad_recovery.device_reassigned.connect(_on_device_reassigned)
	if PlayerManager.replay_requested:
		PlayerManager.replay_requested = false
		prepare_match.call_deferred(true)


func _process(_delta: float) -> void:
	if not round_started:
		return
	for character in players.get_children():
		if not character is Node2D or character.get_child_count() == 0:
			continue
		var penguin := character.get_child(0) as Penguin
		if penguin == null or not is_instance_valid(penguin.feet_marker):
			continue
		# Character scenes use a wrapper Node2D that stays at spawn. Sort by the
		# moving PenguinBase feet instead so the lower penguin draws in front.
		var depth := roundi(penguin.feet_marker.global_position.y * PLAYER_DEPTH_Z_PER_PIXEL)
		character.z_index = clampi(depth, -PLAYER_DEPTH_Z_LIMIT, PLAYER_DEPTH_Z_LIMIT)

func prepare_match(skip_tutorial: bool = false) -> void:
	if round_started:
		return
	start_game()
	get_tree().paused = true
	pre_match.open(skip_tutorial)


func _on_tutorial_completed() -> void:
	if not round_finished and not gamepad_recovery.has_missing_players():
		Music.play_combat()
		match_clock.start()
		get_tree().paused = false


func start_game() -> void:
	if round_started:
		return
	round_started = true
	character_select.queue_free()
	PlayerManager.reset_lives()
	spawn_players()
	$SharedCamera.follow_players(players)
	$ArenaHUD.show_players(PlayerManager.players)
	for character in players.get_children():
		$ArenaHUD.bind_penguin(character.get_child(0) as Penguin)
	gamepad_recovery.begin_round()


func spawn_players() -> void:
	for player_data in PlayerManager.players:
		spawn_player(player_data)


func spawn_player(player_data: Dictionary) -> void:
	var character_data: CharacterData = player_data.get("character")
	if character_data == null or character_data.character_scene == null:
		push_error("Cannot spawn player without a character scene: %s" % player_data)
		return
	var penguin: Node = character_data.character_scene.instantiate()
	var slot: int = player_data["slot"]
	var device: int = player_data["device"]

	penguin.get_child(0).setup(
		slot,
		device
	)

	players.add_child(penguin)

	penguin.global_position = spawn_points[slot].global_position
	var player_body := penguin.get_child(0) as Penguin
	var anchors := PackedVector2Array()
	for marker in spawn_points:
		anchors.append(marker.global_position)
	player_body.configure_arena($Arena/IceArea/Ground, anchors)
	player_body.eliminated.connect(_on_player_eliminated)


func _on_player_eliminated(_slot: int) -> void:
	if round_started and not round_finished:
		_check_round_result.call_deferred()


func _check_round_result() -> void:
	if not round_started or round_finished:
		return
	var survivors: Array[int] = []
	for player in PlayerManager.players:
		var slot: int = player["slot"]
		if PlayerManager.get_lives(slot) > 0:
			survivors.append(slot)
	if survivors.size() > 1:
		return
	_finish_round(survivors[0] if survivors.size() == 1 else -1)


func _on_time_limit_reached() -> void:
	if not round_started or round_finished:
		return
	_check_round_result()
	if round_finished:
		return
	var contenders: Array[Dictionary] = []
	var most_lives := 0
	for character in players.get_children():
		var penguin := character.get_child(0) as Penguin
		if penguin == null:
			continue
		var lives: int = PlayerManager.get_lives(penguin.player_index)
		if lives <= 0 or lives < most_lives:
			continue
		if lives > most_lives:
			most_lives = lives
			contenders.clear()
		var health: float = penguin.max_health if penguin.is_dead else penguin.current_health
		contenders.append({"slot": penguin.player_index, "health": health})
	if contenders.size() == 1:
		_finish_round(contenders[0]["slot"], "Time's up! Most lives remaining.")
		return
	var winners: Array[int] = []
	var most_health := -1.0
	for contender in contenders:
		var health: float = contender["health"]
		if is_equal_approx(health, most_health):
			winners.append(contender["slot"])
		elif health > most_health:
			most_health = health
			winners.assign([contender["slot"]])
	if winners.size() == 1:
		_finish_round(winners[0], "Time's up! Highest HP after tied lives.")
	else:
		_finish_round(-1, "Time's up! Equal lives and HP.")


func _finish_round(winner_slot: int, reason: String = "") -> void:
	if round_finished:
		return
	round_finished = true
	match_clock.stop()
	gamepad_recovery.stop()
	pause_menu.dismiss()
	get_tree().paused = true
	round_result.show_result(winner_slot, reason)


func _replay_round() -> void:
	if not round_finished:
		return
	PlayerManager.replay_requested = true
	get_tree().paused = false
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	if not round_finished and not get_tree().paused:
		return
	PlayerManager.clear_players()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/home/Home.tscn")


func _input(event: InputEvent) -> void:
	if not round_started or round_finished or get_tree().paused or event.is_echo():
		return
	var device := -1
	if event is InputEventJoypadButton:
		device = event.device
		if not MultiplayerInput.device_actions.has(device):
			return
	elif not event is InputEventKey:
		return
	var player: Dictionary = PlayerManager.get_player_by_device(device)
	if player.is_empty() or PlayerManager.get_lives(player["slot"]) <= 0:
		return
	var action: StringName = MultiplayerInput.get_action_name(device, "pause")
	if event.is_action_pressed(action):
		get_viewport().set_input_as_handled()
		pause_menu.open(device, player["slot"])
		get_tree().paused = true


func _resume_round() -> void:
	if not round_finished and not gamepad_recovery.has_missing_players():
		if pre_match.active:
			pre_match.resume()
		else:
			get_tree().paused = false


func _on_recovery_changed(missing_slots: Array[int], choices: Dictionary) -> void:
	if not round_started or round_finished:
		return
	if missing_slots.is_empty() and not pause_menu.shared_control:
		return
	pre_match.suspend()
	get_tree().paused = true
	pause_menu.show_recovery(missing_slots, choices)


func _on_device_reassigned(slot: int, device: int) -> void:
	for character in players.get_children():
		var penguin := character.get_child(0) as Penguin
		if penguin.player_index == slot:
			penguin.rebind_device(device)
			return
