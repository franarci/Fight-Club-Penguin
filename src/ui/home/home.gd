extends Control


@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton


func _ready() -> void:
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	PlayerManager.clear_players()
	get_tree().change_scene_to_file("res://Main.tscn")
