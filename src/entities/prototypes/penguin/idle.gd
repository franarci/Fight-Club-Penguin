extends PenguinState


func enter() -> void:
	player.play_animation(&"idle")


func physics_update(delta: float) -> void:
	var input_dir := player.get_input_direction()

	if input_dir != Vector2.ZERO:
		player.update_facing(input_dir)

		if MultiplayerInput.is_action_just_pressed(player.device,"p1_dash") and player.can_dash:
			player.dash_direction = input_dir.normalized()
			state_machine.change_state(&"Dash")
			return

		state_machine.change_state(&"Walk")
		return

	# Aunque no haya input, seguimos deslizando
	player.apply_ice_friction(delta)
