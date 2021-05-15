extends KinematicBody2D

onready var player_anim : AnimationPlayer = $Body/AnimationPlayer
onready var body : Node2D = $Body/BodyPoints
onready var tween : Tween = $Body/Tween

onready var rocket_launcher_sprite := $Attack/Weapons/RocketLauncher
onready var rocket_launcher_anim := $Attack/Weapons/RocketLauncher/RocketLauncherAnim
onready var rocket_position := $Attack/Weapons/RocketLauncher/RocketPosition

onready var RocketRed = load("res://Weapons/RocketRed.tscn")
onready var RocketBlue = load("res://Weapons/RocketBlue.tscn")
onready var RocketGreen = load("res://Weapons/RocketGreen.tscn")

onready var attack_bar : TextureProgress = $Attack/AttackCharge
onready var attack_timer : Timer = $Attack/AttackTimer

onready var bar_increase : AudioStreamPlayer = $Sounds/BarIncrease
onready var bar_decrease : AudioStreamPlayer = $Sounds/BarDecrease
onready var bar_perfect : AudioStreamPlayer = $Sounds/BarPerfect
onready var bar_good : AudioStreamPlayer = $Sounds/BarGood
onready var bar_bad : AudioStreamPlayer = $Sounds/BarBad
onready var bar_fail : AudioStreamPlayer = $Sounds/BarFail

var max_speed = 600
var velocity = 0
var accel = 160
var decel = -400
var past_move_dir = Vector2()

var level_tracker = SignalHandler.level

var facing_right = true

var bar_is_increasing = false
var bar_val_increasing = 1
var bar_increment = 200
var bar_perfect_min = 95
var bar_good_min = 70
var bar_min = 26

func _ready():
	if SignalHandler.player_pos != null:
		position = SignalHandler.player_pos
	player_anim.play("Idle")

func _physics_process(delta):
	if SignalHandler.boss_defeated:
		play_anim("Idle")
	if SignalHandler.dialog_is_active:
		return
	var move_dir = Vector2()
	
	if Input.is_action_pressed("move_right"):
		move_dir.x += 1
	if Input.is_action_pressed("move_left"):
		move_dir.x -= 1
	if Input.is_action_pressed("move_up"):
		move_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		move_dir.y += 1
	
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		past_move_dir = move_dir
		velocity += accel
		play_anim("Run")
	else:
		velocity -= accel
		play_anim("Idle")
	
	velocity = clamp(velocity, 0, max_speed)
	
	move_and_slide(Vector2(velocity, 0).rotated(past_move_dir.angle()))
	
	if facing_right and move_dir.x < 0:
		flip()
	if !facing_right and move_dir.x > 0:
		flip()
	if SignalHandler.level>level_tracker:
		level_tracker = SignalHandler.level
		bar_is_increasing = false
		bar_val_increasing = 1
		attack_bar.value = 0
	if not SignalHandler.dialog_is_active:
		var bar_val = attack_bar.value
		set_weapon_rot()
		if Input.is_action_just_pressed("Attack") and attack_timer.is_stopped() and not bar_is_increasing:
			bar_is_increasing = true
			bar_increase.play()
			bar_decrease.stop()
		elif Input.is_action_just_released("Attack") and bar_is_increasing:
			bar_is_increasing = false
			if bar_val >= bar_perfect_min:
				bar_perfect.play()
				attack("red")
				pass
			elif bar_val >= bar_good_min:
				bar_good.play()
				attack("green")
				pass
			elif bar_val >= bar_min:
				bar_bad.play()
				attack("blue")
				pass
			else:
				bar_fail.play()
				pass
			bar_val_increasing = 1
			attack_bar.value = 0
			bar_decrease.stop()
			bar_increase.stop()
		if bar_is_increasing:
			attack_bar.value += bar_increment*delta*bar_val_increasing
#			attack_bar.tint_progress.r = (255-(1-bar_val/100)*51)
			if bar_val_increasing > 0:
				bar_decrease.stop()
				if not bar_increase.is_playing():
					bar_increase.play()
			else:
				bar_increase.stop()
				if not bar_decrease.is_playing():
					bar_decrease.play()
			if bar_val >= 100 and bar_val_increasing == 1:
				bar_val_increasing *= -1
			if bar_val <= 0 and bar_val_increasing == -1:
				bar_val_increasing *= -1
		else:
			bar_decrease.stop()
			bar_increase.stop()
			attack_bar.value = 0
			bar_val_increasing = 1

func play_anim(anim_name, player=player_anim):
	if player.is_playing() and player.current_animation == anim_name:
		return
	player.play(anim_name)

func flip():
	facing_right = !facing_right
	body.scale.x *= -1

func attack(type):
	rocket_launcher_anim.play("Shoot")
	var mouse_rad = ((get_local_mouse_position()+(Vector2(0, 5))).angle())
	var mouse_deg = rad2deg(mouse_rad)
	
	match type:
		"red":
			var rocket = RocketRed.instance()
			rocket.position = rocket_position.global_position
			rocket.rotation_degrees = mouse_deg
			rocket.velocity = rocket.velocity.rotated(mouse_rad)
			get_parent().add_child(rocket)
		"green":
			var rocket = RocketGreen.instance()
			rocket.position = rocket_position.global_position
			rocket.rotation_degrees = mouse_deg
			rocket.velocity = rocket.velocity.rotated(mouse_rad)
			get_parent().add_child(rocket)
		"blue":
			var rocket = RocketBlue.instance()
			rocket.position = rocket_position.global_position
			rocket.rotation_degrees = mouse_deg
			rocket.velocity = rocket.velocity.rotated(mouse_rad)
			get_parent().add_child(rocket)


func set_weapon_rot():
	var mouse_rad = ((get_local_mouse_position()+(Vector2(0, 5))).angle())
	var mouse_deg = rad2deg(mouse_rad)
	if mouse_deg > 90 or mouse_deg < -90:
		rocket_launcher_sprite.scale.x = -1
		rocket_launcher_sprite.rotation_degrees = mouse_deg+180
	else:
		rocket_launcher_sprite.scale.x = 1
		rocket_launcher_sprite.rotation_degrees = mouse_deg
