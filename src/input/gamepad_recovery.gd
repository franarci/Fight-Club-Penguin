extends Node

signal recovery_changed(missing_slots: Array[int], choices: Dictionary)
signal device_reassigned(slot: int, device: int)

var round_active := false
var profiles: Dictionary = {}
var missing: Dictionary = {}
var pending: Dictionary = {}


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_connection_changed)


func begin_round(identities: Dictionary = {}) -> void:
	round_active = true
	profiles.clear()
	missing.clear()
	pending.clear()
	for player in PlayerManager.players:
		var device: int = player["device"]
		if device >= 0 and PlayerManager.get_lives(player["slot"]) > 0:
			var identity: Dictionary = identities.get(device, _describe_device(device))
			profiles[player["slot"]] = {"device": device, "identity": identity}


func stop() -> void:
	round_active = false
	pending.clear()
	missing.clear()


func has_missing_players() -> bool:
	return not missing.is_empty()


func _describe_device(device: int) -> Dictionary:
	if not Input.get_connected_joypads().has(device):
		return {"guid": "", "name": "", "serial": ""}
	var info := Input.get_joy_info(device)
	return {"guid": Input.get_joy_guid(device), "name": Input.get_joy_name(device), "serial": str(info.get("serial", ""))}


func _on_connection_changed(device: int, connected: bool) -> void:
	handle_connection(device, connected, _describe_device(device) if connected else {})


func handle_connection(device: int, connected: bool, identity: Dictionary = {}) -> void:
	if not round_active:
		return
	if connected:
		if missing.is_empty() or _is_assigned(device):
			return
		pending[device] = identity
	else:
		pending.erase(device)
		for slot in profiles:
			if profiles[slot]["device"] == device and not missing.has(slot) and PlayerManager.get_lives(slot) > 0:
				missing[slot] = profiles[slot]["identity"]
				PlayerManager.set_device(slot, -100 - int(slot))
	_resolve_connections()
	_notify()


func _is_assigned(device: int) -> bool:
	for slot in profiles:
		if not missing.has(slot) and profiles[slot]["device"] == device:
			return true
	return false


func _matches(saved: Dictionary, incoming: Dictionary) -> bool:
	var saved_serial: String = saved.get("serial", "")
	var incoming_serial: String = incoming.get("serial", "")
	if not saved_serial.is_empty() and not incoming_serial.is_empty():
		return saved_serial == incoming_serial
	var guid: String = saved.get("guid", "")
	var incoming_guid: String = incoming.get("guid", "")
	if not guid.is_empty() and not incoming_guid.is_empty():
		return guid == incoming_guid
	var model_name: String = saved.get("name", "")
	return not model_name.is_empty() and model_name == incoming.get("name", "")


func _matching_slots(identity: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for slot in missing:
		if _matches(missing[slot], identity):
			result.append(slot)
	result.sort()
	return result


func _resolve_connections() -> void:
	var changed := true
	while changed:
		changed = false
		for device in pending.keys():
			var candidates := _matching_slots(pending[device])
			if candidates.size() != 1:
				continue
			var competing := 0
			for other in pending:
				if _matching_slots(pending[other]).has(candidates[0]):
					competing += 1
			if competing == 1 and _assign(candidates[0], device):
				changed = true
				break


func _assign(slot: int, device: int) -> bool:
	if not PlayerManager.set_device(slot, device):
		return false
	profiles[slot] = {"device": device, "identity": pending[device]}
	pending.erase(device)
	missing.erase(slot)
	device_reassigned.emit(slot, device)
	return true


func choose_slot(device: int, slot: int) -> void:
	var choices := get_choices()
	if not choices.has(device) or not choices[device].has(slot):
		return
	_assign(slot, device)
	_resolve_connections()
	_notify()


func get_choices() -> Dictionary:
	var result: Dictionary = {}
	for device in pending:
		var candidates := _matching_slots(pending[device])
		if candidates.is_empty():
			for slot in missing:
				candidates.append(slot)
			candidates.sort()
		if not candidates.is_empty():
			result[device] = candidates
	return result


func _notify() -> void:
	var slots: Array[int] = []
	for slot in missing:
		slots.append(slot)
	slots.sort()
	recovery_changed.emit(slots, get_choices())
