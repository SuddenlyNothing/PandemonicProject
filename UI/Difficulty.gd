extends Control

onready var easy := $VBoxContainer/HBoxContainer/Easy
onready var medium := $VBoxContainer/HBoxContainer/Medium
onready var hard := $VBoxContainer/HBoxContainer/Hard

var faded_a = 0.2

func _ready():
	change_difficulty(SignalHandler.difficulty)

func _on_Easy_pressed():
	change_difficulty("easy")

func _on_Medium_pressed():
	change_difficulty("medium")

func _on_Hard_pressed():
	change_difficulty("hard")

func change_difficulty(dif):
	match dif:
		"easy":
			easy.self_modulate.a = 1
			medium.self_modulate.a = faded_a
			hard.self_modulate.a = faded_a
			SignalHandler.difficulty = "easy"
		"medium":
			medium.self_modulate.a = 1
			easy.self_modulate.a = faded_a
			hard.self_modulate.a = faded_a
			SignalHandler.difficulty = "medium"
		"hard":
			hard.self_modulate.a = 1
			easy.self_modulate.a = faded_a
			medium.self_modulate.a = faded_a
			SignalHandler.difficulty = "hard"
		
		





