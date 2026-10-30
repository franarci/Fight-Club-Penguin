extends Node

const GUNNER = preload("uid://dppv4b2b7ef31")
const HUNTER = preload("uid://sej7wre0em41")
const DEMOLISHER = preload("uid://bplqlfsdkfml5")
const EXPLORER = preload("uid://8d2uraygf2eo")

@onready var character_select = $MenuLayer/CharacterSelect
@onready var players: Node2D = $Players
@onready var round_result = $RoundResult
@onready var pause_menu = $PauseMenu
@onready var gamepad_recovery = $GamepadRecovery
@onready var pre_match = $PreMatch

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
	$SharedCamera.show_arena($Arena.world_size)
	pre_match.completed.connect(_on_tutorial_completed)
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

func prepare_match(skip_tutorial: bool = false) -> void:
	if round_started:
		return
	start_game()
	get_tree().paused = true
	pre_match.open(skip_tutorial)


func _on_tutorial_completed() -> void:
	if not round_finished and not gamepad_recovery.has_missing_players():
		Music.play_combat()
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
	var character: String = player_data["character"].key
	var penguin: Node
	
	if character == "Gunner":
		penguin = GUNNER.instantiate()
	elif character == "Demolisher":
		penguin = DEMOLISHER.instantiate()
	elif character == "Explorer":
		penguin = EXPLORER.instantiate()
	else:
		penguin = HUNTER.instantiate()
	var slot: int = player_data["slot"]
	var device: int = player_data["device"]

	penguin.get_child(0).setup(
		slot,
		device
	)

	players.add_child(penguin)

	penguin.global_position = spawn_points[slot].global_position
	var player_body := penguin.get_child(0) as Penguin
	player_body.configure_arena($Arena/IceArea/Ground)
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
	round_finished = true
	gamepad_recovery.stop()
	pause_menu.dismiss()
	get_tree().paused = true
	round_result.show_result(survivors[0] if survivors.size() == 1 else -1)


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
