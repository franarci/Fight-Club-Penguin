extends Control

const COUNTDOWN_STEPS := ["3", "2", "1", "GO!"]
const COUNTDOWN_STEP_DURATION := 1.0

const PlayerSelector = preload("res://src/ui/character_selection/PlayerSelection.tscn")
@onready var players_container: HBoxContainer = $CenterContainer/PlayersContainer
@onready var countdown: Timer = $Countdown
@onready var countdown_overlay = $CountdownOverlay

@export var player_selection_scene: PackedScene

var player_slots: Array[PlayerSelection] = []
var returning_to_menu := false
var countdown_step := -1
var game_starting := false

func _ready() -> void:
	for child in players_container.get_children():
		if child is PlayerSelection:
			player_slots.append(child)

	for slot in player_slots:
		slot.deactivate()

func _process(_delta: float) -> void:
	if returning_to_menu or game_starting:
		return
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
		cancel_countdown()
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
	if returning_to_menu or game_starting:
		return
	if are_all_players_ready():
		finish_character_selection()
	else:
		cancel_countdown()


func finish_character_selection() -> void:
	if countdown_step >= 0 or returning_to_menu or game_starting:
		return
	if not are_all_players_ready():
		return
	countdown_step = 0
	show_countdown_step()


func show_countdown_step() -> void:
	countdown_overlay.show_step(COUNTDOWN_STEPS[countdown_step], COUNTDOWN_STEP_DURATION)
	countdown.start(COUNTDOWN_STEP_DURATION)


func cancel_countdown() -> void:
	countdown.stop()
	countdown_step = -1
	countdown_overlay.cancel()


func _on_countdown_timeout() -> void:
	if returning_to_menu or game_starting or countdown_step < 0:
		return
	if not are_all_players_ready():
		cancel_countdown()
		return
	countdown_step += 1
	if countdown_step < COUNTDOWN_STEPS.size():
		show_countdown_step()
	else:
		_start_game_if_ready.call_deferred()


func _start_game_if_ready() -> void:
	if returning_to_menu or game_starting or countdown_step != COUNTDOWN_STEPS.size():
		return
	if not are_all_players_ready():
		cancel_countdown()
		return
	game_starting = true
	cancel_countdown()
	set_process(false)
	hide()
	get_parent().start_game()


func _input(event: InputEvent) -> void:
	if returning_to_menu or not is_visible_in_tree():
		return

	if not PlayerManager.players.is_empty():
		return

	if event.is_echo():
		return

	var device: int = -1

	if event is InputEventJoypadButton:
		device = event.device

		if not MultiplayerInput.device_actions.has(device):
			return
	elif not event is InputEventKey:
		return

	var action: StringName = MultiplayerInput.get_action_name(
		device,
		"selection_cancel"
	)

	if event.is_action_pressed(action):
		get_viewport().set_input_as_handled()
		_return_to_menu()


func _return_to_menu() -> void:
	if returning_to_menu:
		return
	returning_to_menu = true
	cancel_countdown()
	set_process(false)
	PlayerManager.clear_players()
	get_tree().change_scene_to_file.call_deferred("res://src/ui/home/Home.tscn")
