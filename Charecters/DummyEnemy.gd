extends Node2D

export(PackedScene) var Enemy

onready var torso = $Body/Torso
onready var shadow = $Body/Shadow
onready var head = $Body/Torso/Head
onready var lefteye = $Body/Torso/Head/LeftEye
onready var righteye = $Body/Torso/Head/RightEye
onready var leftarm = $Body/Torso/LeftArm
onready var rightarm = $Body/Torso/RightArm

func _ready():
	torso.position.y -= 600
	shadow.self_modulate.a = 0

func summon():
	var enemy = Enemy.instance()
	match enemy.name:
		"BadGuyWeak":
			pass
		"BadGuy":
			$Body/Torso/Torso2.visible = true
			$SpringySprites/LeftEye/HealthBar.visible = true
		"BadGuyCamo":
			body_invis()
			$Body/Torso/Camo.visible = true
			$SpringySprites/CamoH.visible = true
			$SpringySprites/CamoLE.visible = true
			$SpringySprites/CamoRE.visible = true
			$SpringySprites/CamoRA.visible = true
			$SpringySprites/CamoLA.visible = true
		"BadGuyFast":
			$Body/Torso/Fast.visible = true
			$SpringySprites/FastH.visible = true
			$SpringySprites/FastLA.visible = true
			$SpringySprites/FastRA.visible = true
	$Tween.interpolate_property(shadow, "self_modulate:a", 0, 1, 1, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(torso, "position:y", null, torso.position.y+600, 1)
	$Tween.start()
	visible = true
	$Timer.start(1)
	yield($Timer, "timeout")
	enemy.position = position
	get_parent().add_child(enemy)
	torso.position.y -= 600
	visible = false

func body_invis():
	torso.visible = false
	head.visible = false
	lefteye.visible = false
	righteye.visible = false
	leftarm.visible =false
	rightarm.visible = false
