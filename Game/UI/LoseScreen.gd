extends Control

var started = false

func _ready():
	$ColorRect.modulate.a = 0
	$ColorRect2.modulate.a = 0
	rect_position = Vector2(100000, 0)
	$ColorRect2.modulate.a = 0
	started = false
	buttons_set_disabled(true)

func _process(_delta):
	if SignalHandler.lost and !started:
		start()

func start():
	if SignalHandler.boss:
		$ColorRect/ColorRect/Label.text = "Everyone Was Infected"
	get_tree().paused = true
	$LoseSound.play()
	rect_position = Vector2(0, 0)
	
	started = true
	SignalHandler.can_pause = false
	$ColorRect2.modulate.a = 0
	$Tween.interpolate_property($ColorRect, "modulate:a", 0, 1, 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property($ColorRect2, "modulate:a", 0, 1, 2, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.5)
	$Tween.start()

func _input(event):
	if event.is_action_pressed("Attack") and started:
		if $Tween.is_active():
			if $ColorRect.modulate.a != 1:
				$Tween.stop_all()
				$ColorRect.modulate.a = 1
				$Tween.interpolate_property($ColorRect2, "modulate:a", 0, 1, 2, 
					Tween.TRANS_LINEAR, Tween.EASE_IN, 1.5)
				$Tween.start()
			elif $ColorRect2.modulate.a != 1:
				$ButtonTimer.start()
				$Tween.stop_all()
				$ColorRect2.modulate.a = 1

func _on_Tween_tween_completed(object, key):
	if object == $ColorRect2:
		$ButtonTimer.start()

func _on_ButtonTimer_timeout():
	buttons_set_disabled(false)

func _on_Menu_pressed():
	SignalHandler.can_pause = true
	get_tree().paused = false
	get_tree().change_scene("res://UI/MainMenu.tscn")

func buttons_set_disabled(val):
	$ColorRect2/Quit.set_disabled(val)
	$ColorRect2/Retry.set_disabled(val)
	$ColorRect2/Menu.set_disabled(val)
