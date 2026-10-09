extends Node

const GUNNER = preload("uid://dppv4b2b7ef31")
const HUNTER = preload("uid://sej7wre0em41")
const DEMOLISHER = preload("uid://bplqlfsdkfml5")
const EXPLORER = preload("uid://8d2uraygf2eo")

@onready var character_select = $CharacterSelect
@onready var players: Node2D = $Players
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
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.get_connected_joypads()
	#MultiplayerInput._create_actions_for_device(0)
	#MultiplayerInput._create_actions_for_device(1)

func start_game() -> void:
	character_select.queue_free()
	PlayerManager.reset_lives()
	spawn_players()
	$ArenaHUD.show_players(PlayerManager.players)


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
