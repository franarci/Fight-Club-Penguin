extends Control

signal closed

@onready var music_mute: CheckBox = $Dim/Center/Panel/Margin/Content/MusicMute
@onready var music_slider: HSlider = $Dim/Center/Panel/Margin/Content/MusicVolume/Slider
@onready var music_value: Label = $Dim/Center/Panel/Margin/Content/MusicVolume/Value
@onready var fx_mute: CheckBox = $Dim/Center/Panel/Margin/Content/FxMute
@onready var fx_slider: HSlider = $Dim/Center/Panel/Margin/Content/FxVolume/Slider
@onready var fx_value: Label = $Dim/Center/Panel/Margin/Content/FxVolume/Value
@onready var back_button: Button = $Dim/Center/Panel/Margin/Content/Back

var owner_device := -1
var shared_control := false
var held_direction := 0
var repeat_delay := 0.0


func _ready() -> void:
	theme = theme.duplicate()
	theme.default_font = SystemFont.new()
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)
	theme.set_color("font_shadow_color", "Label", Color(0.94, 0.12, 0.21, 1))
	theme.set_icon("checked", "CheckBox", preload("res://src/ui/options/icons/checkbox_checked.svg"))
	theme.set_icon("unchecked", "CheckBox", preload("res://src/ui/options/icons/checkbox_unchecked.svg"))
	theme.set_color("checkbox_checked_color", "CheckBox", Color.WHITE)
	theme.set_color("checkbox_unchecked_color", "CheckBox", Color.WHITE)
	theme.set_constant("h_separation", "CheckBox", 12)
	theme.set_stylebox("hover_pressed", "CheckBox", theme.get_stylebox("pressed", "Button"))
	hide()
	music_mute.toggled.connect(func(value: bool): AudioSettings.set_muted(&"Music", value))
	fx_mute.toggled.connect(func(value: bool): AudioSettings.set_muted(&"FX", value))
	music_slider.value_changed.connect(func(value: float): AudioSettings.set_volume(&"Music", value))
	fx_slider.value_changed.connect(func(value: float): AudioSettings.set_volume(&"FX", value))
	back_button.pressed.connect(close)
	AudioSettings.changed.connect(_refresh)
	_refresh()


func open(device: int = -1, shared: bool = false) -> void:
	owner_device = device
	shared_control = shared
	held_direction = 0
	repeat_delay = 0.0
	_refresh()
	show()
	music_mute.grab_focus()


func close() -> void:
	if not visible:
		return
	hide()
	closed.emit()


func _refresh() -> void:
	music_mute.set_pressed_no_signal(AudioSettings.muted[&"Music"])
	fx_mute.set_pressed_no_signal(AudioSettings.muted[&"FX"])
	music_slider.set_value_no_signal(AudioSettings.volumes[&"Music"])
	fx_slider.set_value_no_signal(AudioSettings.volumes[&"FX"])
	music_value.text = "%d%%" % roundi(music_slider.value)
	fx_value.text = "%d%%" % roundi(fx_slider.value)


func _controls() -> Array[Control]:
	return [music_mute, music_slider, fx_mute, fx_slider, back_button]


func _move_focus(direction: int) -> void:
	var controls := _controls()
	var index := controls.find(get_viewport().gui_get_focus_owner())
	controls[posmod(index + direction, controls.size())].grab_focus()


func _adjust_volume(direction: int) -> void:
	var slider := get_viewport().gui_get_focus_owner() as HSlider
	if slider != null and _controls().has(slider):
		slider.value = clampf(slider.value + direction * 5.0, slider.min_value, slider.max_value)


func _process(delta: float) -> void:
	if not visible:
		return
	var devices: Array = [-1] + MultiplayerInput.device_actions.keys() if shared_control else [owner_device]
	var direction := 0
	for device in devices:
		if device != -1 and not MultiplayerInput.device_actions.has(device):
			continue
		if MultiplayerInput.is_action_just_pressed(device, "up"):
			_move_focus(-1)
		elif MultiplayerInput.is_action_just_pressed(device, "down"):
			_move_focus(1)
		if MultiplayerInput.is_action_pressed(device, "left"):
			direction = -1
		elif MultiplayerInput.is_action_pressed(device, "right"):
			direction = 1
	if direction == 0:
		held_direction = 0
	elif direction != held_direction:
		held_direction = direction
		repeat_delay = 0.35
		_adjust_volume(direction)
	else:
		repeat_delay -= delta
		if repeat_delay <= 0.0:
			repeat_delay = 0.08
			_adjust_volume(direction)


func handle_input(event: InputEvent) -> void:
	var is_joy := event is InputEventJoypadButton or event is InputEventJoypadMotion
	var device: int = event.device if is_joy else -1
	var available: bool = device == -1 or MultiplayerInput.device_actions.has(device)
	if not available or (not shared_control and device != owner_device):
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouse:
		return
	get_viewport().set_input_as_handled()
	var cancel: StringName = MultiplayerInput.get_action_name(device, "selection_cancel")
	var pause: StringName = MultiplayerInput.get_action_name(device, "pause")
	var accept: StringName = MultiplayerInput.get_action_name(device, "selection_accept")
	if event.is_action_pressed(cancel) or event.is_action_pressed(pause):
		close()
	elif not event.is_echo() and (event.is_action_pressed(accept) or (event is InputEventKey and event.is_action_pressed("ui_accept"))):
		var focused := get_viewport().gui_get_focus_owner() as BaseButton
		if focused != null and _controls().has(focused):
			if focused is CheckBox:
				focused.button_pressed = not focused.button_pressed
			else:
				focused.pressed.emit()
	elif event is InputEventKey:
		if event.is_action_pressed("ui_up"):
			_move_focus(-1)
		elif event.is_action_pressed("ui_down"):
			_move_focus(1)
		elif event.is_action_pressed("ui_left"):
			_adjust_volume(-1)
		elif event.is_action_pressed("ui_right"):
			_adjust_volume(1)
		elif event.is_action_pressed("ui_focus_prev"):
			_move_focus(-1)
		elif event.is_action_pressed("ui_focus_next"):
			_move_focus(1)
