extends Node

const GUNNER = preload("uid://dppv4b2b7ef31")
const HUNTER = preload("uid://sej7wre0em41")
const DEMOLISHER = preload("uid://bplqlfsdkfml5")
const EXPLORER = preload("uid://8d2uraygf2eo")

@onready var character_select = $CharacterSelect
@onready var players: Node2D = $Players
@onready var round_result = $RoundResult

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
	round_result.replay_requested.connect(_replay_round)
	round_result.menu_requested.connect(_return_to_menu)
	if PlayerManager.replay_requested:
		PlayerManager.replay_requested = false
		start_game.call_deferred()

func start_game() -> void:
	if round_started:
		return
	round_started = true
	character_select.queue_free()
	PlayerManager.reset_lives()
	spawn_players()
	$ArenaHUD.show_players(PlayerManager.players)
	for character in players.get_children():
		$ArenaHUD.bind_penguin(character.get_child(0) as Penguin)


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
	player_body.configure_arena($Ice)
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
	get_tree().paused = true
	round_result.show_result(survivors[0] if survivors.size() == 1 else -1)


func _replay_round() -> void:
	if not round_finished:
		return
	PlayerManager.replay_requested = true
	get_tree().paused = false
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	if not round_finished:
		return
	PlayerManager.clear_players()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/home/Home.tscn")
