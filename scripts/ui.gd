extends Control

var paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if $Pause/Settings.visible:
			$Pause/Settings.visible = false
			return
			
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


func _on_close_settings_pressed() -> void:
	$Pause/Settings.visible = false


func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100)


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value / 100)


func _on_sound_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value / 100)


func _on_suicide_pressed() -> void:
	pass # Replace with function body.
