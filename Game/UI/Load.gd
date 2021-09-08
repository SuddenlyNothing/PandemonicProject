extends ColorRect

signal fade_out

func _ready():
	$Tween.interpolate_property(self, "modulate:a", null, 0, 1)
	$Tween.start()
	visible = true

func fade_out():
	$Tween.interpolate_property(self, "modulate:a", null, 1, 1)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("fade_out")
