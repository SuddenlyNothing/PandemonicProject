extends Control

onready var t := $Tween
onready var warning := $ColorRect

func warning():
	t.playback_speed = 1
	warn()

func very_warning():
	t.playback_speed = 5
	warn()

func warn():
	if !t.is_active():
		print("hello")
		t.interpolate_property(warning, "self_modulate:a", 0, 0.1, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		t.interpolate_property(warning, "self_modulate:a", 0.1, 0, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 2)
	start()

func start():
	show()
	t.start()

func stop():
	hide()
	t.remove_all()
