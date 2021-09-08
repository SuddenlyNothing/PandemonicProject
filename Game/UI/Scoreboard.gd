extends Control

onready var goodgc := $GoodGuyCounter
onready var badgc := $BadGuyCounter
onready var sbt := $ScoreboardTween
onready var sut := $ShowUpTween

export(bool) var hidden = false

signal shown

func _ready():
	goodgc.text = "0"
	badgc.text = "0"
	if hidden == false:
		rect_global_position.y = 0

func _process(delta):
	if SignalHandler.boss:
		visible = false
	if int(goodgc.text) > SignalHandler.num_good_guys:
		jump_bad()
	elif int(badgc.text) > SignalHandler.num_bad_guys:
		jump_good()
	
	goodgc.text = str(SignalHandler.num_good_guys)
	badgc.text = str(SignalHandler.num_bad_guys)

func jump_good():
	sbt.interpolate_property(goodgc, "rect_global_position:y", null, 70, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	sbt.interpolate_property(goodgc, "rect_global_position:y", 70, 104, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT, 0.2)
	sbt.start()

func jump_bad():
	sbt.interpolate_property(badgc, "rect_global_position:y", null, 70, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	sbt.interpolate_property(badgc, "rect_global_position:y", 70, 104, 0.1, Tween.TRANS_SINE, Tween.EASE_IN, 0.2)
	sbt.start()

func show_up():
	sut.interpolate_property(self, "rect_scale:y", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3)
	sut.interpolate_property(self, "rect_global_position:y", 1000, 100, 0.5, Tween.TRANS_SINE, Tween.EASE_IN, 0.3)
	sut.interpolate_property(self, "rect_global_position:y", 100, 0, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.8)
	sut.start()
	yield(sut, "tween_all_completed")
	emit_signal("shown")

func _on_ShowUpTween_tween_started(object, key):
	visible = true
