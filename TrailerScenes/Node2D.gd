extends Node2D

var rng = RandomNumberGenerator.new()
signal completed

func _ready():
	struggle()

func struggle():
	while visible:
		for child in get_children():
			child.offset.x = rng.randf_range(-0.5, 0.5)
			child.offset.y = rng.randf_range(-0.5, 0.5)
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
