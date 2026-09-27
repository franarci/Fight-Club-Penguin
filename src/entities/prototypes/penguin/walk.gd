extends PenguinState
@onready var penguin_base: Penguin = $"../.."


func enter() -> void:
	player.play_animation(&"walk")


func physics_update(delta: float) -> void:
	var input_dir := player.get_input_direction()

	if input_dir == Vector2.ZERO:
		state_machine.change_state(&"Idle")
		return

	player.update_facing(input_dir)

	if MultiplayerInput.is_action_just_pressed(player.device, "p1_dash") and player.can_dash:
		player.dash_direction = input_dir.normalized()
		state_machine.change_state(&"Dash")
		return

	player.apply_ice_movement(input_dir, delta)

	player.play_animation(&"walk")
