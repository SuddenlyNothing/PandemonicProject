extends Button

func _on_Retry_pressed():
	SignalHandler.reset_vars()
	get_tree().paused = false
	get_tree().reload_current_scene()
