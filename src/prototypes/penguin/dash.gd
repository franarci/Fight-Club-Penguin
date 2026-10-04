extends PenguinState


var time_left := 0.0


func enter() -> void:
	time_left = player.dash_duration

	player.start_dash_cooldown()

	player.velocity = (
		player.dash_direction
		* player.dash_speed
	)

	player.play_animation(&"dash")


func physics_update(delta: float) -> void:
	time_left -= delta

	if time_left <= 0.0:
		var input_dir := player.get_input_direction()

		if input_dir == Vector2.ZERO:
			state_machine.change_state(&"Idle")
		else:
			state_machine.change_state(&"Walk")
