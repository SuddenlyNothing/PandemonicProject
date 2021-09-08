extends Sprite

func _ready():
	$StaticBody2D.add_to_group("StaticBodies")

func _on_Area2D_area_entered(area):
	if area.name == "Player":
		$Tween.stop_all()
		$Tween.interpolate_property(self, "self_modulate", null, Color(1, 1, 1, 0.6), 0.2)
		$Tween.interpolate_property($Bottom, "self_modulate", null, Color(1, 1, 1, 0.6), 0.2)
		$Tween.start()


func _on_Area2D_area_exited(area):
	if area.name == "Player":
		$Tween.stop_all()
		$Tween.interpolate_property(self, "self_modulate", null, Color(1, 1, 1, 1), 0.2)
		$Tween.interpolate_property($Bottom, "self_modulate", null, Color(1, 1, 1, 1), 0.2)
		$Tween.start()
