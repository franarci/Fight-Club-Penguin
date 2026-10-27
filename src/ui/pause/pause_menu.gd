extends CanvasLayer

signal resume_requested
signal menu_requested

@onready var continue_button: Button = $Background/CenterContainer/MainPanel/Margin/Content/ContinueButton
@onready var exit_button: Button = $Background/CenterContainer/MainPanel/Margin/Content/ExitButton
@onready var owner_label: Label = $Background/CenterContainer/MainPanel/Margin/Content/OwnerLabel
@onready var confirmation: ColorRect = $Confirmation
@onready var confirm_exit: Button = $Confirmation/CenterContainer/ConfirmPanel/Margin/Content/ExitButton
@onready var cancel_exit: Button = $Confirmation/CenterContainer/ConfirmPanel/Margin/Content/CancelButton

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
	active = true
	owner_label.text = "Pausa del jugador %d" % (slot + 1)
	confirmation.hide()
	show()
	continue_button.grab_focus()


func _process(_delta: float) -> void:
	if not active or not _owner_available():
		return
	if MultiplayerInput.is_action_just_pressed(owner_device, "up") or MultiplayerInput.is_action_just_pressed(owner_device, "left"):
		_move_focus(-1)
	elif MultiplayerInput.is_action_just_pressed(owner_device, "down") or MultiplayerInput.is_action_just_pressed(owner_device, "right"):
		_move_focus(1)


func _input(event: InputEvent) -> void:
	if not active:
		return
	if not _is_owner_event(event):
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouse:
		return
	get_viewport().set_input_as_handled()
	if event.is_echo() or not _owner_available():
		return
	var accept: StringName = MultiplayerInput.get_action_name(owner_device, "selection_accept")
	var cancel: StringName = MultiplayerInput.get_action_name(owner_device, "selection_cancel")
	var pause: StringName = MultiplayerInput.get_action_name(owner_device, "pause")
	if event.is_action_pressed(cancel) or event.is_action_pressed(pause):
		if confirmation.visible:
			_hide_confirmation()
		else:
			_resume()
	elif event.is_action_pressed(accept) or (event is InputEventKey and event.is_action_pressed("ui_accept")):
		var focused := get_viewport().gui_get_focus_owner() as Button
		if _buttons().has(focused):
			focused.pressed.emit()
	elif event is InputEventKey:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
			_move_focus(-1)
		elif event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
			_move_focus(1)


func _is_owner_event(event: InputEvent) -> bool:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return owner_device >= 0 and event.device == owner_device
	if event is InputEventKey or event is InputEventMouse:
		return owner_device == -1
	return false


func _owner_available() -> bool:
	return owner_device == -1 or MultiplayerInput.device_actions.has(owner_device)


func _buttons() -> Array[Button]:
	if confirmation.visible:
		return [cancel_exit, confirm_exit]
	return [continue_button, exit_button]


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
	confirmation.hide()
	hide()


func _resume() -> void:
	if not active:
		return
	active = false
	hide()
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
