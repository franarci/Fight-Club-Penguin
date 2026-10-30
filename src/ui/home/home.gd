extends Control


@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton


func _ready() -> void:
	Music.play_menu()
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	PlayerManager.clear_players()
	get_tree().change_scene_to_file("res://Main.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventJoypadButton:
		return

	if not MultiplayerInput.device_actions.has(event.device):
		return

	var action: StringName = MultiplayerInput.get_action_name(
		event.device,
		"selection_accept"
	)

	if event.is_action_pressed(action):
		var focused_button := get_viewport().gui_get_focus_owner() as Button

		if focused_button != null and not focused_button.disabled:
			get_viewport().set_input_as_handled()
			focused_button.pressed.emit()
