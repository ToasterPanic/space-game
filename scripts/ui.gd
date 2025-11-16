extends Control

var paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = !paused
		
		if paused:
			$Pause.visible = true
			get_tree().paused = true
			AudioServer.set_bus_effect_enabled(1, 0, true)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			$Pause.visible = false
			get_tree().paused = false
			AudioServer.set_bus_effect_enabled(1, 0, false)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
