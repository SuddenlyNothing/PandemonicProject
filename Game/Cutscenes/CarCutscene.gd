extends Node2D

onready var truck = $truck
onready var tw = $Tween
onready var p = $DummyPlayer

onready var gg = $CanvasLayer/GiveGun
onready var gt = $CanvasLayer/GiveTracker
onready var gun = $Launcher
onready var scoreboard = $CanvasLayer/Scoreboard
onready var gb = $CanvasLayer/Goodbye

export(String, FILE, "*.tscn") var level1

func _ready():
	truck.loud(1)
	truck.drive()
	tw.interpolate_property(truck, "position:x", -328, 0, 2, Tween.TRANS_SINE, Tween.EASE_OUT)
	tw.start()
	truck.stop_car()
	yield(truck, "stopped")
	truck.open_close_door()
	yield(truck, "door_opened")
	p.visible = true
	yield(truck, "door_closed")
	tw.interpolate_property(p, "position", Vector2(6, 32), Vector2(48, 26), 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tw.start()
	yield(tw, "tween_all_completed")
	p.get_node("Body").scale.x *= -1
	
	gg.start()
	yield(gg, "dialogue_finished")
	
	gun.visible = true
	tw.interpolate_property(gun, "position:x", 10, 49, 2)
	tw.interpolate_property(gun, "position:y", 25, -9, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	tw.interpolate_property(gun, "position:y", -9, 24, 1, Tween.TRANS_SINE, Tween.EASE_IN, 1)
	tw.start()
	
	yield(tw, "tween_all_completed")
	gun.visible = false
	p.show_gun()
	gt.start()
	yield(gt, "dialogue_finished")
	
	scoreboard.show_up()
	yield(scoreboard, "shown")
	print("scoreboard shown")
	
	gb.start()
	yield(gb, "dialogue_finished")
	
	truck.start_car()
	yield(truck, "started")
	tw.interpolate_property(truck, "position:x", 0, 382, 2, Tween.TRANS_SINE, Tween.EASE_IN, 0.7)
	tw.start()
	truck.quiet(5)
	yield(tw, "tween_all_completed")
	$CanvasLayer/Load.fade_out()
	yield($CanvasLayer/Load, "fade_out")
	get_tree().change_scene(level1)
