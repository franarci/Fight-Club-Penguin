extends Control

signal selection_finished

const ControlHints = preload("res://src/ui/shared/control_hints.gd")
const ControlPrompt = preload("res://src/ui/shared/control_prompt.gd")

@onready var players_container: HBoxContainer = $CenterContainer/PlayersContainer
@onready var footer_actions: HBoxContainer = $Footer/Margin/Actions
@onready var ready_dialog: Control = $ReadyDialog
@onready var ready_prompts: HBoxContainer = $ReadyDialog/Center/Panel/Margin/Content/Prompts

@export var player_selection_scene: PackedScene

var player_slots: Array[PlayerSelection] = []
var returning_to_menu := false
var game_starting := false
var dialog_dismissed := false
var dialog_armed := false
var waiting_for_release := false


func _ready() -> void:
	for child in players_container.get_children():
		if child is PlayerSelection:
			player_slots.append(child)
	for slot in player_slots:
		slot.preview_changed.connect(_update_footer)
		slot.deactivate()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	$ReadyDialog/Center/Panel/Margin/Content/Buttons/Accept.pressed.connect(finish_character_selection)
	$ReadyDialog/Center/Panel/Margin/Content/Buttons/Cancel.pressed.connect(_dismiss_ready_dialog)
	_refresh_selection()


func _process(_delta: float) -> void:
	if returning_to_menu or game_starting:
		return
	if ready_dialog.visible:
		if _selection_buttons_released():
			dialog_armed = true
		return
	if waiting_for_release:
		if _selection_buttons_released():
			waiting_for_release = false
			_set_slots_processing(true)
		return
	check_keyboard_join()
	check_gamepads_join()


func check_keyboard_join() -> void:
	if not PlayerManager.is_device_joined(-1) and MultiplayerInput.is_action_just_pressed(-1, "player_join"):
		activate_player_slot(-1)


func check_gamepads_join() -> void:
	for device in Input.get_connected_joypads():
		if not PlayerManager.is_device_joined(device) and MultiplayerInput.device_actions.has(device):
			if MultiplayerInput.is_action_just_pressed(device, "player_join"):
				activate_player_slot(device)


func activate_player_slot(device: int) -> void:
	if returning_to_menu or game_starting or ready_dialog.visible:
		return
	var free_slot := get_free_slot()
	if free_slot == -1:
		return
	if PlayerManager.join_player(device, free_slot):
		player_slots[free_slot].activate(device, free_slot)
		dialog_dismissed = false
		_refresh_selection()


func get_free_slot() -> int:
	for i in range(player_slots.size()):
		if not player_slots[i].active:
			return i
	return -1


func are_all_players_ready() -> bool:
	if PlayerManager.players.size() < 2:
		return false
	for player in PlayerManager.players:
		if not player["ready"]:
			return false
	return true


func _on_player_ready_changed() -> void:
	if not returning_to_menu and not game_starting:
		dialog_dismissed = false
		_refresh_selection()


func _participant_devices() -> Array:
	var devices: Array = []
	for player in PlayerManager.players:
		devices.append(player["device"])
	return devices


func _available_devices() -> Array:
	var devices: Array = [-1]
	for device in Input.get_connected_joypads():
		if MultiplayerInput.device_actions.has(device):
			devices.append(device)
	return devices


func _refresh_selection() -> void:
	if ready_dialog.visible and not are_all_players_ready():
		_close_ready_dialog()
	_update_footer()
	if are_all_players_ready() and not dialog_dismissed and not ready_dialog.visible:
		_open_ready_dialog.call_deferred()


func _update_footer() -> void:
	_clear_children(footer_actions)
	var choosing: Array = []
	var can_select: Array = []
	for player in PlayerManager.players:
		if not player["ready"]:
			choosing.append(player["device"])
			var card := player_slots[player["slot"]]
			if card.characters[card.selected_character].selectable:
				can_select.append(player["device"])
	if not can_select.is_empty():
		_add_prompt(footer_actions, "Select character", can_select, ["selection_accept"])
	var participants := _participant_devices()
	if not participants.is_empty():
		_add_prompt(footer_actions, "Change character" if choosing.is_empty() else "Back", participants, ["selection_cancel"])
	else:
		_add_prompt(footer_actions, "Main menu", _available_devices(), ["selection_cancel"])
	if are_all_players_ready():
		_add_prompt(footer_actions, "Start match", participants, ["player_join"])
	elif get_free_slot() >= 0:
		var unjoined: Array = []
		for device in _available_devices():
			if not PlayerManager.is_device_joined(device):
				unjoined.append(device)
		if not unjoined.is_empty():
			_add_prompt(footer_actions, "Join", unjoined, ["player_join"])


func _add_prompt(parent: Node, caption: String, devices: Array, actions: Array) -> void:
	var prompt := ControlPrompt.new()
	prompt.configure(caption, devices, actions)
	parent.add_child(prompt)


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func _open_ready_dialog() -> void:
	if returning_to_menu or game_starting or not are_all_players_ready() or ready_dialog.visible or dialog_dismissed:
		return
	dialog_armed = false
	_set_slots_processing(false)
	_clear_children(ready_prompts)
	_add_prompt(ready_prompts, "Let's play", _participant_devices(), ["menu_confirm"])
	_add_prompt(ready_prompts, "Keep choosing", _participant_devices(), ["selection_cancel"])
	ready_dialog.show()


func _close_ready_dialog() -> void:
	ready_dialog.hide()
	dialog_armed = false
	waiting_for_release = true


func _dismiss_ready_dialog() -> void:
	dialog_dismissed = true
	_close_ready_dialog()
	_update_footer()


func _selection_buttons_released() -> bool:
	for device in _participant_devices():
		if device >= 0 and not MultiplayerInput.device_actions.has(device):
			continue
		for action in ["selection_accept", "selection_cancel", "player_join"]:
			if MultiplayerInput.is_action_pressed(device, action):
				return false
	return true


func _set_slots_processing(enabled: bool) -> void:
	for slot in player_slots:
		slot.set_process(enabled)


func finish_character_selection() -> void:
	if returning_to_menu or game_starting or not ready_dialog.visible or not are_all_players_ready():
		return
	game_starting = true
	set_process(false)
	_set_slots_processing(false)
	hide()
	selection_finished.emit()


func _input(event: InputEvent) -> void:
	if returning_to_menu or game_starting or not is_visible_in_tree() or event.is_echo():
		return
	var device := -1
	if event is InputEventJoypadButton:
		device = event.device
		if not MultiplayerInput.device_actions.has(device):
			return
	elif not event is InputEventKey:
		return
	var cancel: StringName = MultiplayerInput.get_action_name(device, "selection_cancel")
	if ready_dialog.visible:
		get_viewport().set_input_as_handled()
		if not dialog_armed or PlayerManager.get_player_by_device(device).is_empty():
			return
		if event.is_action_pressed(cancel):
			_dismiss_ready_dialog()
		elif event.is_action_pressed(MultiplayerInput.get_action_name(device, ControlHints.confirmation_action(device))):
			finish_character_selection()
	elif PlayerManager.players.is_empty():
		if event.is_action_pressed(cancel):
			get_viewport().set_input_as_handled()
			_return_to_menu()
	elif are_all_players_ready() and not PlayerManager.get_player_by_device(device).is_empty():
		if event.is_action_pressed(MultiplayerInput.get_action_name(device, "player_join")):
			get_viewport().set_input_as_handled()
			dialog_dismissed = false
			_open_ready_dialog()


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if returning_to_menu or game_starting:
		return
	if ready_dialog.visible:
		_close_ready_dialog()
	if not connected:
		for slot in player_slots:
			if slot.active and slot.device == device:
				slot.deactivate()
				dialog_dismissed = false
	_refresh_selection()


func _return_to_menu() -> void:
	if returning_to_menu:
		return
	returning_to_menu = true
	set_process(false)
	PlayerManager.clear_players()
	get_tree().change_scene_to_file.call_deferred("res://src/ui/home/Home.tscn")
