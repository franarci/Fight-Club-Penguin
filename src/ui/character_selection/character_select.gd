extends Control

const PlayerSelector = preload("res://src/ui/character_selection/PlayerSelection.tscn")
@onready var players_container: HBoxContainer = $CenterContainer/PlayersContainer
@onready var countdown: Timer = $Countdown

@export var player_selection_scene: PackedScene

var player_slots: Array[PlayerSelection] = []

func _ready() -> void:
	for child in players_container.get_children():
		if child is PlayerSelection:
			player_slots.append(child)

	for slot in player_slots:
		slot.deactivate()

func _process(_delta: float) -> void:
	check_keyboard_join()
	check_gamepads_join()


func check_keyboard_join() -> void:
	var device := -1

	if PlayerManager.is_device_joined(device):
		return

	if MultiplayerInput.is_action_just_pressed(device, "player_join"):
		activate_player_slot(device)


func check_gamepads_join() -> void:
	for device in Input.get_connected_joypads():

		if PlayerManager.is_device_joined(device):
			continue

		if MultiplayerInput.is_action_just_pressed(device, "player_join"):
			activate_player_slot(device)

func activate_player_slot(device: int):
	var free_slot := get_free_slot()

	if free_slot == -1:
		return

	if PlayerManager.join_player(device, free_slot):
		player_slots[free_slot].activate(
			device,
			free_slot
		)

func get_free_slot() -> int:
	for i in range(player_slots.size()):
		if not player_slots[i].active:
			return i

	return -1
	
func are_all_players_ready() -> bool:
	if PlayerManager.players.size() <= 1:
		return false

	for player in PlayerManager.players:
		if not player["ready"]:
			return false

	return true

func _on_player_ready_changed() -> void:
	if are_all_players_ready():
		finish_character_selection()
	elif !countdown.is_stopped():
		countdown.stop()

func finish_character_selection() -> void:
	countdown.start()
	
	
func _on_countdown_timeout() -> void:
	hide()
	get_parent().start_game()
