extends Control

var started = false
var menu = "res://UI/MainMenu.tscn"
var credits = "res://UI/Credits.tscn"


onready var button1 = $ColorRect2/Quit
onready var button2 = $ColorRect2/Continue

signal write_player_pos

func _ready():
	$ColorRect.modulate.a = 0
	$ColorRect2.modulate.a = 0
	rect_position = Vector2(100000, 0)
	buttons_set_disabled(true)
	$ColorRect2.modulate.a = 0
	started = false

func _process(_delta):
	if SignalHandler.boss:
		if SignalHandler.boss_defeated_show_winscreen and !started:
			$ColorRect2/Menu.visible = false
			$ColorRect2/Menu.disabled = true
			start()
	elif SignalHandler.won and !started:
		start()

func start():
	rect_position = Vector2(0, 0)
	$ColorRect/Label.text = "Wave " +str(SignalHandler.level+1)+" Cleared"
	if SignalHandler.level == 7:
		$ColorRect/Label.text = "You Saved Everyone"
	$WinSound.play()
	started = true
	SignalHandler.can_pause = false
	get_tree().paused = true
	$ColorRect2.modulate.a = 0
	$Tween.interpolate_property($ColorRect, "modulate:a", 0, 1, 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property($ColorRect2, "modulate:a", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.5)
	$Tween.start()
	SignalHandler.level += 1

func _input(event):
	if Input.is_action_just_pressed("Attack") and started:
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

func _on_Tween_tween_completed(object, _key):
	if object == $ColorRect2:
		$ButtonTimer.start()

func _on_ButtonTimer_timeout():
	buttons_set_disabled(false)

func _on_Continue_pressed():
	if SignalHandler.boss_defeated_show_winscreen:
		get_tree().change_scene(credits)
		get_tree().paused = false
		SignalHandler.clear_memory()
		return
	SignalHandler.won = false
	var store_good_pos = []
	for i in get_tree().get_nodes_in_group("good_guys"):
		store_good_pos.append(i.position)
	SignalHandler.good_guys_pos = store_good_pos
	started = false
	buttons_set_disabled(true)
	$Tween2.interpolate_property($ColorRect, "modulate:a", 1, 0, 0.1)
	$Tween2.interpolate_property($ColorRect2, "modulate:a", 1, 0, 0.1)
	$Tween2.start()
	yield($Tween2, "tween_completed")
	rect_position = Vector2(100000, 0)
	get_tree().paused = false
	SignalHandler.can_pause = true

func write_info():
	emit_signal("write_player_pos")
	SignalHandler.won = false
	SignalHandler.can_pause = true
	var store_good_pos = []
	for i in get_tree().get_nodes_in_group("good_guys"):
		store_good_pos.append(i.position)
	SignalHandler.good_guys_pos = store_good_pos
	get_tree().paused = false


func _on_Menu_pressed():
	if SignalHandler.boss_defeated:
		get_tree().change_scene(credits)
		get_tree().paused = false
		SignalHandler.clear_memory()
		return
	print('yo the info of the good_guys is writing rn')
	write_info()
	get_tree().change_scene("res://UI/MainMenu.tscn")

func buttons_set_disabled(val):
	$ColorRect2/Quit.set_disabled(val)
	$ColorRect2/Continue.set_disabled(val)
	$ColorRect2/Menu.set_disabled(val)
