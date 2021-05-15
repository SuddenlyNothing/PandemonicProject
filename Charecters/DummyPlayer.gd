extends Node2D

func _ready():
	$AnimationPlayer.play("Idle")

func show_gun():
	$Body/Torso/Gun.visible = true
