extends Sprite

var num_people = 0
var tween_ready = false

func _on_Area2D_area_entered(area):
	if num_people == 0:
		if tween_ready:
			$Tween.stop_all()
			$Tween.interpolate_property(self, "self_modulate", null, Color(1, 1, 1, 0.4), 0.2)
			$Tween.start()
		else:
			self_modulate.a = 0.4
	num_people += 1

func _on_Area2D_area_exited(area):
	if !$Tween.is_inside_tree():
		return
	num_people -= 1
	if num_people <= 0:
		num_people = 0
		if tween_ready:
			$Tween.stop_all()
			$Tween.interpolate_property(self, "self_modulate", null, Color(1, 1, 1, 1), 0.2)
			$Tween.start()
		else:
			self_modulate.a = 1


func _on_Tween_ready():
	tween_ready = true
