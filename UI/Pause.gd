extends Control

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel") and SignalHandler.can_pause:
		var new_pause_state = not get_tree().paused
		get_tree().paused = not get_tree().paused
		visible = new_pause_state


func _on_Menu_pressed():
	SignalHandler.revert_to_save()
	get_tree().paused = false
	get_tree().change_scene("res://UI/MainMenu.tscn")
