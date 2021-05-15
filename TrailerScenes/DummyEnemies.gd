extends Node2D

var rng = RandomNumberGenerator.new()

#func _ready():
#	for child in get_children():
#		print(rng.randi_range(0, 1))
#		if rng.randi_range(0, 1) ==1:
#			child.get_node("Body").scale.x*=-1

func flip():
	for child in get_children():
		if rng.randi_range(0, 4) ==1:
			if child.has_method("_ready"):
				child.get_node("Body").scale.x*=-1

func _on_Flip_timeout():
	flip()
	$Flip.wait_time = rng.randf_range(0, 0.2)
