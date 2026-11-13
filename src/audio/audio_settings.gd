extends Node

signal changed

const BUSES: Array[StringName] = [&"Music", &"FX"]

var volumes: Dictionary = {&"Music": 100.0, &"FX": 100.0}
var muted: Dictionary = {&"Music": false, &"FX": false}
var reference_levels: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in BUSES:
		var index := AudioServer.get_bus_index(bus)
		assert(index >= 0)
		reference_levels[bus] = AudioServer.get_bus_volume_linear(index)
		muted[bus] = AudioServer.is_bus_mute(index)


func set_volume(bus: StringName, percentage: float) -> void:
	assert(BUSES.has(bus))
	volumes[bus] = clampf(percentage, 0.0, 100.0)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), reference_levels[bus] * volumes[bus] / 100.0)
	changed.emit()


func set_muted(bus: StringName, value: bool) -> void:
	assert(BUSES.has(bus))
	muted[bus] = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), value)
	changed.emit()
