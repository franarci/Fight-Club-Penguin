extends Node


const MAX_PLAYERS := 4
const STARTING_LIVES := 3
signal lives_changed(slot: int, lives: int)
const PLAYER_COLORS := [
	Color("#e74c3c"),
	Color("#2796ff"),
	Color("#9c764a"),
	Color("#2ecc71")
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
		"ready": false,
		"lives": STARTING_LIVES
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


func reset_lives() -> void:
	for player in players:
		player["lives"] = STARTING_LIVES
		lives_changed.emit(player["slot"], STARTING_LIVES)


func set_lives(slot: int, lives: int) -> void:
	for player in players:
		if player["slot"] == slot:
			var remaining := clampi(lives, 0, STARTING_LIVES)
			if player.get("lives", STARTING_LIVES) != remaining:
				player["lives"] = remaining
				lives_changed.emit(slot, remaining)
			return


func lose_life(slot: int) -> void:
	for player in players:
		if player["slot"] == slot:
			set_lives(slot, int(player.get("lives", STARTING_LIVES)) - 1)
			return

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
