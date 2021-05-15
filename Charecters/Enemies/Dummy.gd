extends KinematicBody2D

var FCT = preload("res://UI/FTC.tscn")

func damage(value, crit=false):
	var fct = FCT.instance()
	add_child(fct)
	fct.show_value(str(value), crit)

func _on_Area2D_area_entered(area):
	var damage_source = area.get_owner()
	if damage_source.has_method("get_damage_crit"):
		var d = damage_source.get_damage_crit()
		damage(d[0], d[1])
