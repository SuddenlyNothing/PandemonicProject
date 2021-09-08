extends Button

export(String, FILE, "*.tscn") var next_scene

func _on_Retry_pressed():
	SignalHandler.reset_vars()
	get_tree().paused = false
	get_tree().change_scene(next_scene)
