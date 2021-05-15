extends Node2D

onready var t := $Tween
onready var s := $Hand_SanitizerGreen
onready var h := $Scientist/GoodGuyArm4
var Explosion = preload("res://Weapons/ExplosionGreen.tscn")

var duration = 0.5

var shake_dur = 0.05
var num_shakes = 5

func _ready():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	for i in range(num_shakes):
		t.interpolate_property(h, "position:y", h.position.y, h.position.y+2, shake_dur, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		t.interpolate_property(h, "position:y", h.position.y+2, h.position.y, shake_dur, Tween.TRANS_SINE, Tween.EASE_IN_OUT, shake_dur)
		t.interpolate_property(s, "position:y", s.position.y, s.position.y+2, shake_dur, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		t.interpolate_property(s, "position:y", s.position.y+2, s.position.y, shake_dur, Tween.TRANS_SINE, Tween.EASE_IN_OUT, shake_dur)
		t.start()
		yield(t, "tween_all_completed")
	t.playback_speed = 0.5
	t.interpolate_property(s, "position:x", s.position.x, s.position.x+50, duration)
	t.interpolate_property(s, "position:y", s.position.y, s.position.y-10, duration/2, Tween.TRANS_SINE, Tween.EASE_OUT)
	t.interpolate_property(s, "position:y", s.position.y-10, s.position.y, duration/2, Tween.TRANS_SINE, Tween.EASE_IN, duration/2)
	t.start()
	yield(t, "tween_all_completed")
	s.hide()
	var explosion = Explosion.instance()
	explosion.position = Vector2.ZERO
	explosion.scale = Vector2.ONE
	add_child(explosion)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$Bad.hide()
	$Good.show()

func _process(delta):
	$Camera2D.position.x = s.position.x
