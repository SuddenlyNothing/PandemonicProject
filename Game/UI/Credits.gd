extends Control

func _on_Menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://UI/MainMenu.tscn")
