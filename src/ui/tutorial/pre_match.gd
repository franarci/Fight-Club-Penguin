extends CanvasLayer

signal completed

const ControlHints = preload("res://src/ui/shared/control_hints.gd")
const ControlPrompt = preload("res://src/ui/shared/control_prompt.gd")
const COUNTDOWN_STEPS := ["3", "2", "1", "GO!"]
const STEP_DURATION := 1.0

@onready var background: ColorRect = $Background
@onready var title: Label = $Background/Center/Panel/Margin/Content/Title
@onready var objective: Label = $Background/Center/Panel/Margin/Content/Objective
@onready var controls: HBoxContainer = $Background/Center/Panel/Margin/Content/Controls
@onready var next_button: Button = $Background/Center/Panel/Margin/Content/NextButton
@onready var hint: HBoxContainer = $Background/Center/Panel/Margin/Content/Hint
@onready var countdown: Timer = $Countdown
@onready var countdown_overlay = $CountdownOverlay

var active := false
var suspended := false
var page := 0
var countdown_step := -1


func _ready() -> void:
	hide()
	next_button.pressed.connect(advance)
	countdown.timeout.connect(_on_countdown_timeout)


func open(skip_tutorial: bool = false) -> void:
	active = true
	suspended = false
	page = 0
	countdown_step = -1
	show()
	if skip_tutorial:
		start_countdown()
	else:
		_build_controls()
		_show_page()


func _build_controls() -> void:
	_clear_children(controls)
	_clear_children(hint)
	var families := PackedStringArray()
	var devices: Array = []
	for player in PlayerManager.players:
		var device: int = player["device"]
		devices.append(device)
		var family: String = ControlHints.device_family(device)
		if families.has(family):
			continue
		families.append(family)
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 12)
		var title_label := Label.new()
		title_label.text = family
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 20)
		column.add_child(title_label)
		for action in ["movement", "dash", "attack", "pause"]:
			var captions := {"movement": "Move", "dash": "Dash / push", "attack": "Attack", "pause": "Pause"}
			var prompt := ControlPrompt.new()
			prompt.configure(captions[action], [device], [action])
			column.add_child(prompt)
		controls.add_child(column)
	var advance_prompt := ControlPrompt.new()
	advance_prompt.configure("Continue", devices, ["menu_confirm"])
	hint.add_child(advance_prompt)


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func _show_page() -> void:
	background.show()
	title.text = "How to win" if page == 0 else "Controls"
	objective.visible = page == 0
	controls.visible = page == 1
	next_button.text = "Next" if page == 0 else "Start countdown"
	next_button.grab_focus()


func advance() -> void:
	if not active or suspended or countdown_step >= 0:
		return
	if page == 0:
		page = 1
		_show_page()
	else:
		start_countdown()


func start_countdown() -> void:
	if not active or suspended or countdown_step >= 0:
		return
	background.hide()
	countdown_step = 0
	_show_countdown_step()


func _input(event: InputEvent) -> void:
	if not active or suspended:
		return
	if event is InputEventMouse:
		return
	if event.is_echo():
		get_viewport().set_input_as_handled()
		return
	var device := -1
	if event is InputEventJoypadButton:
		device = event.device
		if not MultiplayerInput.device_actions.has(device):
			return
	elif not event is InputEventKey:
		return
	get_viewport().set_input_as_handled()
	if PlayerManager.get_player_by_device(device).is_empty():
		return
	if event.is_action_pressed(MultiplayerInput.get_action_name(device, ControlHints.confirmation_action(device))):
		advance()


func _show_countdown_step() -> void:
	countdown_overlay.show_step(COUNTDOWN_STEPS[countdown_step], STEP_DURATION)
	countdown.start(STEP_DURATION)


func _on_countdown_timeout() -> void:
	if not active or suspended or countdown_step < 0:
		return
	countdown_step += 1
	if countdown_step < COUNTDOWN_STEPS.size():
		_show_countdown_step()
	else:
		countdown.stop()
		active = false
		countdown_step = -1
		countdown_overlay.cancel()
		hide()
		completed.emit()


func suspend() -> void:
	if not active:
		return
	suspended = true
	countdown.stop()
	countdown_overlay.cancel()
	hide()


func resume() -> void:
	if not active:
		return
	suspended = false
	show()
	_build_controls()
	if countdown_step >= 0:
		countdown_step = 0
		_show_countdown_step()
	else:
		_show_page()
