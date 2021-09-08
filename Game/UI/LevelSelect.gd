extends Control




func _on_Button_pressed():
	enter_level(0)


func _on_Button2_pressed():
	enter_level(1)


func _on_Button3_pressed():
	enter_level(2)


func _on_Button4_pressed():
	enter_level(3)


func _on_Button5_pressed():
	enter_level(4)


func _on_Button6_pressed():
	enter_level(5)


func _on_Button7_pressed():
	enter_level(6)


func _on_Button8_pressed():
	enter_level(7)


func _on_Button9_pressed():
	get_tree().change_scene("res://UI/MainMenu.tscn")

func _on_Button10_pressed():
	get_tree().change_scene("res://Levels/MainScene.tscn")

func enter_level(level):
	SignalHandler.clear_memory()
	SignalHandler.level = level
	SignalHandler.load_prev_as_innocents = true
	get_tree().change_scene("res://Levels/MainScene.tscn")


