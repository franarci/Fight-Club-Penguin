extends Node


const MAX_PLAYERS := 4
const PLAYER_COLORS := [
	Color("#e74c3c"),
	Color("#f1c40f"),
	Color("#2ecc71"),
	Color("#3498db")
]

var players: Array[Dictionary] = []


func join_player(device: int, slot: int) -> bool:
	if players.size() >= MAX_PLAYERS:
		return false

	if is_device_joined(device):
		return false

	var player_data := {
		"device": device,
		"slot": slot,
		"character": null,
		"ready": false
	}

	players.append(player_data)

	return true

func remove_player(device: int) -> void:
	for i in range(players.size()):
		if players[i]["device"] == device:
			players.remove_at(i)
			return


func is_device_joined(device: int) -> bool:
	for player in players:
		if player["device"] == device:
			return true

	return false


func get_player_by_device(device: int) -> Dictionary:
	for player in players:
		if player["device"] == device:
			return player

	return {}

func get_player_color(slot: int) -> Color:
	return PLAYER_COLORS[slot]

func clear_players() -> void:
	players.clear()

#When player confirms a penguin, save the selection on the player data
func set_character(device: int, character: CharacterData) -> void:
	for player in players:
		if player["device"] == device:
			player["character"] = character
			return


func set_ready(device: int, ready: bool) -> void:
	for player in players:
		if player["device"] == device:
			player["ready"] = ready
			return
