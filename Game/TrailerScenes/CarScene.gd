extends Node2D

func _ready():
	$truck.drive()

func _process(delta):
	$truck.position.x+=3
