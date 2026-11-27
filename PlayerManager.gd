extends Node

const MAX_PLAYERS := 4
const STARTING_LIVES := 3
const MAX_LIVES := 4
const SLOT_ASSIGNMENTS_PATH := "user://player_slot_assignments_v4.cfg"

signal lives_changed(slot: int, lives: int)

const PLAYER_COLORS := [
	Color("#ff3347"),
	Color("#2796ff"),
	Color("#2ecc71"),
	Color("#9c764a")
]

var players: Array[Dictionary] = []
var replay_requested := false
var device_slots: Dictionary = {}
var device_identity_keys: Dictionary = {}
var identity_slots: Dictionary = {}
var slot_identity_keys: Dictionary = {}
var slot_devices: Dictionary = {}


func _ready() -> void:
	_load_slot_assignments()
	if identity_slots.has("keyboard"):
		_register_device_identity(-1, "keyboard")
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_register_connected_devices()


func _load_slot_assignments() -> void:
	var config := ConfigFile.new()
	if config.load(SLOT_ASSIGNMENTS_PATH) != OK:
		return
	for identity_key in config.get_section_keys("assignments"):
		var saved_slots: Array = config.get_value("assignments", identity_key, [])
		for saved_slot_value in saved_slots:
			var saved_slot := int(saved_slot_value)
			if saved_slot < 0 or saved_slot >= MAX_PLAYERS or slot_identity_keys.has(saved_slot):
				continue
			var slots: Array = identity_slots.get(identity_key, [])
			if not slots.has(saved_slot):
				slots.append(saved_slot)
				identity_slots[identity_key] = slots
			slot_identity_keys[saved_slot] = identity_key


func _save_slot_assignments() -> void:
	var config := ConfigFile.new()
	for identity_key in identity_slots:
		config.set_value("assignments", identity_key, identity_slots[identity_key])
	config.save(SLOT_ASSIGNMENTS_PATH)


func _register_connected_devices() -> void:
	var connected_devices := Input.get_connected_joypads()
	connected_devices.sort()
	# Restore saved ports for known controllers; new controllers claim a port only when they join.
	for device in connected_devices:
		_register_known_connected_device(device)


func _register_new_connected_device(device: int) -> int:
	var base_identity := _controller_identity_base(device)
	if base_identity.begins_with("serial:"):
		return _register_device_identity(device, base_identity)
	var identity_key := ""
	for occurrence in range(MAX_PLAYERS):
		var candidate := "%s#%d" % [base_identity, occurrence]
		if not _active_identity_keys().has(candidate):
			identity_key = candidate
			break
	if identity_key.is_empty():
		return -1
	return _register_device_identity(device, identity_key)


func _controller_identity_base(device: int) -> String:
	if device < 0:
		return "keyboard"
	if not Input.get_connected_joypads().has(device):
		return "device:%d" % device
	var info := Input.get_joy_info(device)
	var serial_value: Variant = info.get("serial", "")
	var serial := str(serial_value).strip_edges() if serial_value != null else ""
	if not serial.is_empty():
		return "serial:" + serial
	var guid := Input.get_joy_guid(device)
	if not guid.is_empty():
		return "guid:" + guid
	var device_name := Input.get_joy_name(device).strip_edges()
	return "name:" + device_name if not device_name.is_empty() else "device:%d" % device


func _connected_identity_key(device: int) -> String:
	var base_identity := _controller_identity_base(device)
	if base_identity.begins_with("serial:"):
		return base_identity
	var connected_devices := Input.get_connected_joypads()
	connected_devices.sort()
	var occurrence := 0
	for connected_device in connected_devices:
		if _controller_identity_base(connected_device) != base_identity:
			continue
		if connected_device == device:
			return "%s#%d" % [base_identity, occurrence]
		occurrence += 1
	return "%s#%d" % [base_identity, occurrence]


func _register_known_connected_device(device: int) -> int:
	if not Input.get_connected_joypads().has(device):
		return -1
	var identity_key := _connected_identity_key(device)
	if not identity_slots.has(identity_key):
		return -1
	return _register_device_identity(device, identity_key)


func _active_identity_keys() -> Array:
	return device_identity_keys.values()


func _register_device_identity(device: int, identity_key: String, preferred_slot: int = -1) -> int:
	if device_slots.has(device):
		var existing_identity: String = device_identity_keys.get(device, "")
		if existing_identity == identity_key:
			return int(device_slots[device])
		_release_device_assignment(device)
	var slots: Array = identity_slots.get(identity_key, [])
	var assigned_slot := -1
	for slot_value in slots:
		var candidate_slot := int(slot_value)
		if not slot_devices.has(candidate_slot):
			assigned_slot = candidate_slot
			break
	if assigned_slot < 0 and preferred_slot >= 0 and preferred_slot < MAX_PLAYERS and not slot_identity_keys.has(preferred_slot):
		assigned_slot = preferred_slot
	if assigned_slot < 0:
		assigned_slot = _find_available_slot()
	if assigned_slot < 0:
		return -1
	if not slots.has(assigned_slot):
		slots.append(assigned_slot)
		identity_slots[identity_key] = slots
	slot_identity_keys[assigned_slot] = identity_key
	device_slots[device] = assigned_slot
	device_identity_keys[device] = identity_key
	slot_devices[assigned_slot] = device
	_save_slot_assignments()
	return assigned_slot


func _find_available_slot() -> int:
	for slot in range(MAX_PLAYERS):
		if not slot_identity_keys.has(slot):
			return slot
	for slot in range(MAX_PLAYERS):
		if slot_devices.has(slot):
			continue
		var previous_identity: String = slot_identity_keys.get(slot, "")
		if not previous_identity.is_empty():
			_remove_identity_slot(previous_identity, slot)
		return slot
	return -1


func get_available_slot() -> int:
	for slot in range(MAX_PLAYERS):
		if not slot_identity_keys.has(slot):
			return slot
	for slot in range(MAX_PLAYERS):
		if not slot_devices.has(slot):
			return slot
	return -1


func _remove_identity_slot(identity_key: String, slot: int) -> void:
	var slots: Array = identity_slots.get(identity_key, [])
	slots.erase(slot)
	if slots.is_empty():
		identity_slots.erase(identity_key)
	else:
		identity_slots[identity_key] = slots
	if slot_identity_keys.get(slot, "") == identity_key:
		slot_identity_keys.erase(slot)


func _release_device_assignment(device: int) -> void:
	var slot := int(device_slots.get(device, -1))
	if slot >= 0 and slot_devices.get(slot, -999) == device:
		slot_devices.erase(slot)
	device_slots.erase(device)
	device_identity_keys.erase(device)


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		_register_known_connected_device.call_deferred(device)
	else:
		_release_device_assignment(device)


func get_assigned_slot(device: int) -> int:
	if device_slots.has(device):
		return int(device_slots[device])
	if device < 0:
		if identity_slots.has("keyboard"):
			return _register_device_identity(device, "keyboard")
		return -1
	if Input.get_connected_joypads().has(device):
		return _register_known_connected_device(device)
	return -1


func assign_device_slot(device: int, preferred_slot: int = -1) -> int:
	var assigned_slot := get_assigned_slot(device)
	if assigned_slot >= 0:
		return assigned_slot
	var identity_key := _controller_identity_base(device)
	if device >= 0 and Input.get_connected_joypads().has(device):
		var registered_slot := _register_new_connected_device(device)
		if registered_slot >= 0:
			return registered_slot
		identity_key = "device:%d" % device
	return _register_device_identity(device, identity_key, preferred_slot)


func join_player(device: int, slot: int) -> bool:
	if players.size() >= MAX_PLAYERS or is_device_joined(device):
		return false
	if slot < 0 or slot >= MAX_PLAYERS:
		return false
	var assigned_slot := get_assigned_slot(device)
	if assigned_slot < 0:
		assigned_slot = assign_device_slot(device, slot)
	if assigned_slot != slot:
		if device >= 0 and Input.get_connected_joypads().has(device):
			return false
		if not _move_device_to_slot(device, slot):
			return false
	for player in players:
		if int(player["slot"]) == slot:
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
	replay_requested = false


func reset_lives() -> void:
	for player in players:
		player["lives"] = STARTING_LIVES
		lives_changed.emit(player["slot"], STARTING_LIVES)


func set_lives(slot: int, lives: int) -> void:
	for player in players:
		if player["slot"] == slot:
			var remaining := clampi(lives, 0, MAX_LIVES)
			if player.get("lives", STARTING_LIVES) != remaining:
				player["lives"] = remaining
				lives_changed.emit(slot, remaining)
			return


func get_lives(slot: int) -> int:
	for player in players:
		if player["slot"] == slot:
			return int(player.get("lives", STARTING_LIVES))
	return 0


func lose_life(slot: int) -> void:
	for player in players:
		if player["slot"] == slot:
			set_lives(slot, int(player.get("lives", STARTING_LIVES)) - 1)
			return


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


func set_device(slot: int, device: int) -> bool:
	for player in players:
		if player["slot"] != slot and player["device"] == device:
			return false
	for player in players:
		if int(player["slot"]) != slot:
			continue
		var previous_device := int(player["device"])
		if previous_device != device and previous_device >= 0:
			_release_device_assignment(previous_device)
		if device >= 0:
			var assigned_slot := get_assigned_slot(device)
			if assigned_slot != slot and not _move_device_to_slot(device, slot):
				return false
		player["device"] = device
		return true
	return false


func _move_device_to_slot(device: int, slot: int) -> bool:
	if slot < 0 or slot >= MAX_PLAYERS:
		return false
	if slot_devices.has(slot) and int(slot_devices[slot]) != device:
		return false
	var identity_key: String = device_identity_keys.get(device, "")
	if identity_key.is_empty():
		var registered_slot := assign_device_slot(device, slot)
		if registered_slot < 0:
			return false
		identity_key = device_identity_keys.get(device, "")
		if registered_slot == slot:
			return true
	var previous_slot := int(device_slots.get(device, -1))
	if previous_slot >= 0:
		_release_device_assignment(device)
		_remove_identity_slot(identity_key, previous_slot)
	var previous_identity: String = slot_identity_keys.get(slot, "")
	if not previous_identity.is_empty() and previous_identity != identity_key:
		_remove_identity_slot(previous_identity, slot)
	var slots: Array = identity_slots.get(identity_key, [])
	if not slots.has(slot):
		slots.append(slot)
	identity_slots[identity_key] = slots
	slot_identity_keys[slot] = identity_key
	device_slots[device] = slot
	device_identity_keys[device] = identity_key
	slot_devices[slot] = device
	_save_slot_assignments()
	return true
