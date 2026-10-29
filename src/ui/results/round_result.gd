extends CanvasLayer

signal replay_requested
signal menu_requested

@onready var title: Label = $Background/CenterContainer/PanelContainer/MarginContainer/Content/Title
@onready var replay_button: Button = $Background/CenterContainer/PanelContainer/MarginContainer/Content/ReplayButton
@onready var menu_button: Button = $Background/CenterContainer/PanelContainer/MarginContainer/Content/MenuButton

var active := false


func _ready() -> void:
	hide()
	replay_button.pressed.connect(_on_replay_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func show_result(winner_slot: int) -> void:
	active = true
	title.text = "Draw!" if winner_slot < 0 else "Player %d wins!" % (winner_slot + 1)
	title.add_theme_color_override("font_color", Color.WHITE if winner_slot < 0 else PlayerManager.get_player_color(winner_slot))
	show()
	replay_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not active or not event is InputEventJoypadButton:
		return
	if not MultiplayerInput.device_actions.has(event.device):
		return
	if event.is_action_pressed(MultiplayerInput.get_action_name(event.device, "selection_accept")):
		var button := get_viewport().gui_get_focus_owner() as Button
		if button == replay_button or button == menu_button:
			get_viewport().set_input_as_handled()
			button.pressed.emit()
		return
	for action in ["up", "down", "left", "right"]:
		if event.is_action_pressed(MultiplayerInput.get_action_name(event.device, action)):
			get_viewport().set_input_as_handled()
			if replay_button.has_focus():
				menu_button.grab_focus()
			else:
				replay_button.grab_focus()
			return


func _on_replay_pressed() -> void:
	if not active:
		return
	active = false
	replay_requested.emit()


func _on_menu_pressed() -> void:
	if not active:
		return
	active = false
	menu_requested.emit()
