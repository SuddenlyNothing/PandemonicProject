extends Control

onready var skip := $ColorRect/VBoxContainer/CenterContainer2/Skip

var CarCutscene = "res://Cutscenes/CarCutscene.tscn"
var lvls = "res://Levels/MainScene.tscn"
var level_select = "res://UI/LevelSelect.tscn"
var credits = "res://UI/Credits.tscn"

func _ready():
	$AnimationPlayer.play("title")
	if SignalHandler.level == 0:
		skip.disabled = true


func _on_Start_pressed():
	SignalHandler.clear_memory()
	get_tree().change_scene(CarCutscene)


func _on_Quit_pressed():
	get_tree().quit()


func _on_Skip_pressed():
	get_tree().change_scene(lvls)


func _on_Credits_pressed():
	get_tree().change_scene(credits)

func _on_DebugSkip_pressed():
	get_tree().change_scene(level_select)
