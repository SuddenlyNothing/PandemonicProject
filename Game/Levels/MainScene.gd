extends Node2D

# level 0 easy
# level 1 easy
# level 2 easy thic
# level 3 thic camo
# level 4 thic fast
# level 5 camo fast
# level 6 thic camo fast
# level 7 Boss

var level_tracker = SignalHandler.level

onready var l0 = $YSort/Level0
onready var l1 = $YSort/Level1
onready var l2 = $YSort/Level2
onready var l3 = $YSort/Level3
onready var l4 = $YSort/Level4
onready var l5 = $YSort/Level5
onready var l6 = $YSort/Level6
onready var l7 = $YSort/Level7

var easy = false

onready var GoodGuy = preload("res://Charecters/GoodGuy.tscn")

func _ready():
	SignalHandler.connect("very_near_lost", self, "very_near_lost")
	SignalHandler.connect("near_lost", self, "near_lost")
	SignalHandler.connect("not_lost", self, "not_lost")
	if SignalHandler.level != 7:
			$Sounds/InfectionStepNotLoop.play()
	# place in player
	if SignalHandler.player_pos != null:
		$YSort/Player.position = SignalHandler.player_pos
		
	# place in good_guys
	if SignalHandler.level>0:
		for i in l0.get_children():
			if i.is_in_group("good_guys"):
				SignalHandler.num_good_guys -= 1
			else:
				SignalHandler.num_bad_guys -= 1
			i.call_deferred("queue_free")
		for i in SignalHandler.good_guys_pos:
			var gg = GoodGuy.instance()
			gg.position = i
			gg.get_node("ImmunityTimer").wait_time = 0.001
			l0.add_child(gg)
	
	# place in bad_guys
	load_level(SignalHandler.level)
	
func _process(delta):
	if SignalHandler.level == 7:
		$Sounds/InfectionStepLoop.stop()
		$Sounds/InfectionStepNotLoop.stop()
	if SignalHandler.boss_defeated:
		$Sounds/WhatABossIntro.stop()
		$Sounds/WhatABossLoop.stop()
		$Sounds/WhatABossNotLoop.stop()
	if level_tracker < SignalHandler.level:
		SignalHandler.player_pos = $YSort/Player.position
		load_level(SignalHandler.level)
		level_tracker = SignalHandler.level
	

func load_level(lvl):
	if SignalHandler.load_prev_as_innocents and lvl > 0:
		load_as_good_guys(lvl-1)
	match lvl:
		1:
			for child in l1.get_children():
				child.summon()
				if easy:
					break
			l1.visible = true
		2:
			for child in l2.get_children():
				child.summon()
				if easy:
					break
			l2.visible = true
		3:
			for child in l3.get_children():
				child.summon()
				if easy:
					break
			l3.visible = true
		4:
			for child in l4.get_children():
				child.summon()
				if easy:
					break
			l4.visible = true
		5:
			for child in l5.get_children():
				child.summon()
				if easy:
					break
			l5.visible = true
		6:
			for child in l6.get_children():
				child.summon()
				if easy:
					break
			l6.visible = true
		7:
			$Sounds/InfectionStepNotLoop.stop()
			$Sounds/InfectionStepLoop.stop()
			$CanvasLayer/BossDialog.start()
			SignalHandler.boss = true
			SignalHandler.can_pause = false
			l7.visible = true
			yield($CanvasLayer/BossDialog, "dialogue_finished")
			for child in l7.get_children():
				child.summon()
			yield($YSort/Level7/Boss, "boss_hit_ground")
			$Camera2D.screen_shake()
			yield($YSort/Level7/Boss, "boss_started")
			SignalHandler.can_pause = true
			$Sounds/WhatABossIntro.play()

func load_as_good_guys(level):
	match level:
		0:
			var store_good_pos = []
			for i in get_tree().get_nodes_in_group("good_guys"):
				store_good_pos.append(i.position)
			SignalHandler.good_guys_pos = store_good_pos
			SignalHandler.load_prev_as_innocents = false
		1:
			for child in l1.get_children():
				var gg = GoodGuy.instance()
				gg.position = child.position
				l0.add_child(gg)
			load_as_good_guys(0)
		2:
			for child in l2.get_children():
				var gg = GoodGuy.instance()
				gg.position = child.position
				l0.add_child(gg)
			load_as_good_guys(1)
		3:
			for child in l3.get_children():
				var gg = GoodGuy.instance()
				gg.position = child.position
				l0.add_child(gg)
			load_as_good_guys(2)
		4:
			for child in l4.get_children():
				var gg = GoodGuy.instance()
				gg.position = child.position
				l0.add_child(gg)
			load_as_good_guys(3)
		5:
			for child in l5.get_children():
				var gg = GoodGuy.instance()
				gg.position = child.position
				l0.add_child(gg)
			load_as_good_guys(4)
		6:
			for child in l6.get_children():
				var gg = GoodGuy.instance()
				gg.position = child.position
				l0.add_child(gg)
			load_as_good_guys(5)

func _on_InfectionStepNotLoop_finished():
	$Sounds/InfectionStepLoop.play()

func _on_WhatABoss_finished():
	$Sounds/WhatABossNotLoop.play()

func _on_WhatABossNotLoop_finished():
	$Sounds/WhatABossLoop.play()

func _on_WinScreen_write_player_pos():
	SignalHandler.player_pos = $YSort/Player.position

func very_near_lost():
	$Sounds/InfectionStepLoop.pitch_scale = 1.5
	$Sounds/InfectionStepNotLoop.pitch_scale = 1.5
	$CanvasLayer/Warning.very_warning()
#	print("very_near_lost")

func near_lost():
	$Sounds/InfectionStepLoop.pitch_scale = 1.1
	$Sounds/InfectionStepNotLoop.pitch_scale = 1.1
	$CanvasLayer/Warning.warning()
#	print("near_lost")

func not_lost():
	$Sounds/InfectionStepLoop.pitch_scale = 1
	$Sounds/InfectionStepNotLoop.pitch_scale = 1
	$CanvasLayer/Warning.stop()
#	print("not_lost")
