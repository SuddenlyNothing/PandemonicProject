extends Node2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if rng.randi_range(0, 1) == 0:
		$AnimationPlayer.play("Idle")
	else:
		$AnimationPlayer.play("Celebrate")
	$AnimationPlayer.seek(rng.randf_range(0, 1))
