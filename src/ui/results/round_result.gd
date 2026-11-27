extends CanvasLayer

signal replay_requested
signal menu_requested

const VictoryCelebration = preload("res://src/ui/results/victory_celebration.gd")

@onready var background: Control = $Background
@onready var announcement: Control = $Announcement
@onready var announcement_title: Label = $Announcement/Title
@onready var presentation_timer: Timer = $PresentationTimer
@onready var title: Label = $Background/CenterContainer/PanelContainer/MarginContainer/Content/Title
@onready var reason_label: Label = $Background/CenterContainer/PanelContainer/MarginContainer/Content/Reason
@onready var replay_button: Button = $Background/CenterContainer/PanelContainer/MarginContainer/Content/ReplayButton
@onready var menu_button: Button = $Background/CenterContainer/PanelContainer/MarginContainer/Content/MenuButton

var active := false
var presenting := false
var camera_tween: Tween
var focused_camera: Camera2D
var camera_was_processing := false
var celebration


func _ready() -> void:
	hide()
	replay_button.pressed.connect(_on_replay_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	presentation_timer.timeout.connect(_on_presentation_timeout)


func show_result(winner_slot: int, reason: String = "", camera: Camera2D = null, winner: Penguin = null) -> void:
	_cancel_camera_tween()
	presentation_timer.stop()
	active = false
	presenting = true
	reason_label.text = reason
	reason_label.visible = not reason.is_empty()
	title.text = "Draw!" if winner_slot < 0 else "Player %d wins!" % (winner_slot + 1)
	var color: Color = Color.WHITE if winner_slot < 0 else PlayerManager.get_player_color(winner_slot)
	title.add_theme_color_override("font_color", color)
	announcement_title.text = "DRAW!" if winner_slot < 0 else "PLAYER %d WINS!" % (winner_slot + 1)
	background.hide()
	announcement.hide()
	show()
	if is_instance_valid(camera) and is_instance_valid(winner):
		_focus_winner(camera, winner)
	else:
		_show_announcement(winner)


func _focus_winner(camera: Camera2D, winner: Penguin) -> void:
	winner.respawn_timer.stop()
	winner.death_audio.stop()
	winner.damage_feedback.reset()
	winner.hit_animation_active = false
	winner.death_animation_active = false
	winner.stop_dash_animation()
	if winner.is_dead:
		winner.global_position = winner.respawn_position
	winner.body.sprite_frames = winner.p_spriteframes
	winner.body.show()
	winner.body.self_modulate.a = 1.0
	winner.weapon_socket.show()
	winner.player_indicator.hide()
	winner.show()
	if is_instance_valid(winner.current_weapon):
		if winner.current_weapon.has_method("cancel_attack"):
			winner.current_weapon.cancel_attack()
	winner.update_facing(Vector2(1, 1))
	winner.play_animation(&"idle")
	winner.update_player_identifier()
	var sprite_rect := winner.get_body_display_rect()
	var center := winner.body.to_global(sprite_rect.get_center())
	var world_height := maxf(sprite_rect.size.y * absf(winner.body.global_scale.y), 1.0)
	var target_zoom := clampf(get_viewport().get_visible_rect().size.y * 0.4 / world_height, 2.0, 4.0) * 0.5
	focused_camera = camera
	camera_was_processing = camera.is_processing()
	camera.set_process(false)
	camera.offset = Vector2.ZERO
	camera_tween = create_tween().set_parallel(true)
	camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	camera_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(camera, "global_position", center, 1.2)
	camera_tween.tween_property(camera, "zoom", Vector2.ONE * target_zoom, 1.2)
	camera_tween.finished.connect(_show_announcement.bind(winner), CONNECT_ONE_SHOT)


func _show_announcement(winner: Penguin = null) -> void:
	if not presenting:
		return
	announcement.show()
	if is_instance_valid(winner):
		var kind: StringName = &"Gunner"
		for player in PlayerManager.players:
			if int(player["slot"]) == winner.player_index:
				var data := player.get("character") as CharacterData
				if data != null:
					kind = StringName(data.key)
				break
		celebration = VictoryCelebration.new()
		add_child(celebration)
		celebration.start(winner, kind)
	presentation_timer.start(5.0)


func _on_presentation_timeout() -> void:
	if not presenting:
		return
	presentation_timer.stop()
	presenting = false
	announcement.hide()
	background.show()
	active = true
	replay_button.grab_focus()


func _cancel_camera_tween() -> void:
	if is_instance_valid(celebration):
		celebration.stop()
		celebration.queue_free()
	celebration = null
	if camera_tween != null and camera_tween.is_valid():
		camera_tween.kill()
	camera_tween = null
	if is_instance_valid(focused_camera):
		focused_camera.set_process(camera_was_processing)
	focused_camera = null


func _exit_tree() -> void:
	_cancel_camera_tween()


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
