extends CanvasLayer

signal resume_requested
signal menu_requested
signal recovery_slot_requested(device: int, slot: int)

@onready var continue_button: Button = $Background/CenterContainer/MainPanel/Margin/Content/ContinueButton
@onready var exit_button: Button = $Background/CenterContainer/MainPanel/Margin/Content/ExitButton
@onready var owner_label: Label = $Background/CenterContainer/MainPanel/Margin/Content/OwnerLabel
@onready var confirmation: ColorRect = $Confirmation
@onready var confirm_exit: Button = $Confirmation/CenterContainer/ConfirmPanel/Margin/Content/ExitButton
@onready var cancel_exit: Button = $Confirmation/CenterContainer/ConfirmPanel/Margin/Content/CancelButton

@onready var recovery_choices: VBoxContainer = $Background/CenterContainer/MainPanel/Margin/Content/RecoveryChoices
@onready var recovery_slots: VBoxContainer = $Background/CenterContainer/MainPanel/Margin/Content/RecoveryChoices/Slots

var shared_control := false
var resume_allowed := true
var device_choices: Dictionary = {}
var activating_device := -99
var choice_buttons: Array[Button] = []
var active := false
var owner_device := -99


func _ready() -> void:
	hide()
	confirmation.hide()
	continue_button.pressed.connect(_resume)
	exit_button.pressed.connect(_show_confirmation)
	confirm_exit.pressed.connect(_confirm_exit)
	cancel_exit.pressed.connect(_hide_confirmation)


func open(device: int, slot: int) -> void:
	owner_device = device
	shared_control = false
	resume_allowed = true
	continue_button.disabled = false
	_clear_choices()
	active = true
	owner_label.text = "Paused by player %d" % (slot + 1)
	confirmation.hide()
	show()
	continue_button.grab_focus()


func show_recovery(missing_slots: Array[int], choices: Dictionary) -> void:
	shared_control = true
	active = true
	resume_allowed = missing_slots.is_empty()
	continue_button.disabled = not resume_allowed
	confirmation.hide()
	_clear_choices()
	var names := PackedStringArray()
	for slot in missing_slots:
		names.append(str(slot + 1))
	owner_label.text = "Waiting for controllers for players: " + ", ".join(names) if not resume_allowed else "Controllers reconnected. Select Resume."
	device_choices = choices.duplicate(true)
	if not choices.is_empty():
		for slot in missing_slots:
			var button := Button.new()
			button.text = "I'm player %d" % (slot + 1)
			button.custom_minimum_size.y = 44
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.pressed.connect(_choose_slot.bind(slot))
			recovery_slots.add_child(button)
			choice_buttons.append(button)
		recovery_choices.show()
	show()
	_buttons()[0].grab_focus()


func _clear_choices() -> void:
	for button in choice_buttons:
		recovery_slots.remove_child(button)
		button.queue_free()
	choice_buttons.clear()
	device_choices.clear()
	recovery_choices.hide()


func _choose_slot(slot: int) -> void:
	if shared_control and device_choices.has(activating_device) and device_choices[activating_device].has(slot):
		recovery_slot_requested.emit(activating_device, slot)


func _process(_delta: float) -> void:
	if not active:
		return
	var devices: Array = [-1] + MultiplayerInput.device_actions.keys() if shared_control else [owner_device]
	for device in devices:
		if not _device_available(device):
			continue
		if MultiplayerInput.is_action_just_pressed(device, "up") or MultiplayerInput.is_action_just_pressed(device, "left"):
			_move_focus(-1)
			return
		if MultiplayerInput.is_action_just_pressed(device, "down") or MultiplayerInput.is_action_just_pressed(device, "right"):
			_move_focus(1)
			return


func _input(event: InputEvent) -> void:
	if not active:
		return
	if not _is_owner_event(event):
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouse:
		return
	get_viewport().set_input_as_handled()
	var device: int = event.device if event is InputEventJoypadButton or event is InputEventJoypadMotion else -1
	if event.is_echo() or not _device_available(device):
		return
	var accept: StringName = MultiplayerInput.get_action_name(device, "selection_accept")
	var cancel: StringName = MultiplayerInput.get_action_name(device, "selection_cancel")
	var pause: StringName = MultiplayerInput.get_action_name(device, "pause")
	if event.is_action_pressed(cancel) or event.is_action_pressed(pause):
		if confirmation.visible:
			_hide_confirmation()
		elif not shared_control:
			_resume()
	elif event.is_action_pressed(accept) or (event is InputEventKey and event.is_action_pressed("ui_accept")):
		var focused := get_viewport().gui_get_focus_owner() as Button
		if _buttons().has(focused):
			if choice_buttons.has(focused) and not device_choices.has(device):
				exit_button.grab_focus()
				return
			activating_device = device
			focused.pressed.emit()
			activating_device = -99
	elif event is InputEventKey:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
			_move_focus(-1)
		elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
			_move_focus(1)


func _is_owner_event(event: InputEvent) -> bool:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return _device_available(event.device) and (shared_control or event.device == owner_device)
	if event is InputEventKey or event is InputEventMouse:
		return shared_control or owner_device == -1
	return false


func _device_available(device: int) -> bool:
	return device == -1 or MultiplayerInput.device_actions.has(device)


func _buttons() -> Array[Button]:
	if confirmation.visible:
		return [cancel_exit, confirm_exit]
	var buttons: Array[Button] = []
	buttons.append_array(choice_buttons)
	if resume_allowed:
		buttons.append(continue_button)
	buttons.append(exit_button)
	return buttons


func _move_focus(direction: int) -> void:
	var buttons := _buttons()
	var index: int = buttons.find(get_viewport().gui_get_focus_owner())
	if index < 0:
		index = 0
	else:
		index = posmod(index + direction, buttons.size())
	buttons[index].grab_focus()


func dismiss() -> void:
	active = false
	shared_control = false
	_clear_choices()
	confirmation.hide()
	hide()


func _resume() -> void:
	if not active or not resume_allowed:
		return
	dismiss()
	resume_requested.emit()


func _show_confirmation() -> void:
	if not active:
		return
	confirmation.show()
	cancel_exit.grab_focus()


func _hide_confirmation() -> void:
	confirmation.hide()
	exit_button.grab_focus()


func _confirm_exit() -> void:
	if not active or not confirmation.visible:
		return
	active = false
	hide()
	menu_requested.emit()
