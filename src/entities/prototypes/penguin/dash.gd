extends PenguinState


var time_left := 0.0


func enter() -> void:
	time_left = player.dash_duration
	if is_instance_valid(player.current_weapon) and player.current_weapon.has_method("cancel_charge"):
		player.current_weapon.cancel_charge()

	player.start_dash_cooldown()
	player.play_dash_sound()

	player.velocity = (
		player.dash_direction
		* player.dash_speed
	)

	player.play_animation(&"dash")


func physics_update(delta: float) -> void:
	time_left -= delta
	player.advance_dash_animation(delta)

	if time_left <= 0.0:
		var input_dir := player.get_input_direction()

		if input_dir == Vector2.ZERO:
			state_machine.change_state(&"Idle")
		else:
			state_machine.change_state(&"Walk")
