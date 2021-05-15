extends Node2D

onready var body : Node2D = $Body

onready var nav_2d : Navigation2D = $"../../../Navigation2D"
onready var line2d := $Line2D
onready var anim_player := $AnimationPlayer
onready var hit_sound := $Sounds/Hit
onready var health_bar := $CanvasLayer/HealthBar

onready var hurtbox := $Areas/Hurtbox/CollisionShape2D
onready var hitbox := $Areas/Hitbox/CollisionShape2D

var target
var path
var speed = 490

var rng = RandomNumberGenerator.new()

var started = false
signal boss_hit_ground
signal boss_started

func _ready():
	$SpringySprites.visible = false
	$Body.visible = false
	$Body/Torso.position.y -= 600
	health_bar.visible = false
	set_areas_disabled(true)
	play_anim("Idle")

func summon():
	if SignalHandler.player_pos != null:
		print("set to player pos")
		position = SignalHandler.player_pos+Vector2(50, 0)
	SignalHandler.dialog_is_active = true
	SignalHandler.change_num_bad_guys(1)
	started = true
	anim_player.play("Summon")
	print("played animation summon")
	yield(anim_player, "animation_finished")
	print("Summon animation completed")
	anim_player.play("Idle")
	emit_signal("boss_hit_ground")
	$CanvasLayer/Taunt.start()
	yield($CanvasLayer/Taunt, "dialogue_finished")
	$BlackForeground.interpolate_property($CanvasLayer/BlackForeground, "self_modulate:a", 0, 1, 30)
	$BlackForeground.start()
	emit_signal("boss_started")
	anim_player.play("Run")
	health_bar.visible = true
	show_health_bar()
	set_areas_disabled(false)
	target_random_near()

func _physics_process(delta:float):
	if SignalHandler.dialog_is_active:
		return
	if target == null and started == true and get_tree().get_nodes_in_group("good_guys").size() > 0:
		target_random_near()
	if target != null and target.is_sick:
		target_random_near()
	if target != null:
		path = nav_2d.get_simple_path(position, target.position)
	else:
		return
	play_anim("Run")
	var move_distance = speed*delta
	set_line2d()
	move_along_path(move_distance, delta, speed)

func set_line2d():
	line2d.set_default_color(Color(0.4, 0.5, 1, 1))
	var line_path := PoolVector2Array()
	for i in path:
		line_path.append(to_local(i))
	line2d.points = line_path

func move_along_path(distance: float, delta, speed) -> void:
	var start_point := position
	for i in range(path.size()):
		set_facing_right(path[0])
		# uses how far we move during the process to move on the path towards the target
		var distance_to_next : = start_point.distance_to(path[0])
		if distance_to_next == 0:
			path.remove(0)
			continue
		if distance <= distance_to_next:
			# go towards the target
			var endpoint = start_point.linear_interpolate(path[0], distance/distance_to_next)
			var move_rot = Vector2(endpoint-start_point).angle()
			var motion = Vector2(speed, 0).rotated(move_rot)
			position+=motion*delta
			break
		elif path.size() == 1:
			# go to the final point
			position+=(path[0]-start_point)*delta
			break
		# moves past this point and prepares to move towards the next
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func set_facing_right(pos):
	if pos.x > position.x:
		body.scale.x = 1
	else:
		body.scale.x = -1

func target_near():
	var good_guys = get_tree().get_nodes_in_group("good_guys")
	if !available_good_guy(good_guys):
		play_anim("Idle")
		return
	var nearest
	var gg
	for good_guy in good_guys:
		if good_guy.is_sick:
			continue
		var dist = get_dist_from_pos(good_guy.position)
		if nearest == null:
			nearest = dist
			gg = good_guy
			continue
		if dist < nearest:
			nearest = dist
			gg = good_guy
	target = gg

func get_dist_from_pos(pos):
	var dist = 0
	var p = nav_2d.get_simple_path(position, pos)
	var curr_pos = position
	for i in p:
		dist += curr_pos.distance_to(i)
		curr_pos = i
	return dist

func set_display_over_building(val):
	for i in ["Body/Torso/Torso","SpringySprites/Head","SpringySprites/LeftEye","SpringySprites/RightEye","SpringySprites/LeftArm","SpringySprites/RightArm","Body/Torso/ProgressBar"]:
		var n = get_node_or_null(i)
		if n == null:
			continue
		if val:
			n.z_index = -1
		else:
			n.z_index = 0
	$Body/Torso/Torso2.visible = val
	$SpringySprites/Head2.visible = val
	$SpringySprites/LeftEye2.visible = val
	$SpringySprites/RightEye2.visible = val
	$SpringySprites/LeftArm2.visible = val
	$SpringySprites/RightArm2.visible = val

func _on_Hitbox_area_entered(area):
	hit_sound.play()
	target_random_near()


func _on_Hurtbox_area_entered(area):
	if area.name == "BossBarHide":
		set_boss_health_display(false)
	if area.name == "BuildingShow":
		set_display_over_building(true)
	if area.name == "ExplosionHitbox":
		var dmg = area.get_parent().get_damage()
		health_bar.value -= dmg
		if dmg ==3:
			flash_red()
		else:
			flash_white()
		if health_bar.value <= 0 and SignalHandler.lost == false:
			$BlackForeground.stop_all()
			$BlackForeground.interpolate_property($CanvasLayer/BlackForeground, "self_modulate:a", null, 0, 0.5)
			$BlackForeground.start()
			set_areas_disabled(true)
			SignalHandler.can_pause = false
			SignalHandler.dialog_is_active = true
			SignalHandler.boss_defeated = true
			$CanvasLayer/TextureRect.visible = true
			play_anim("Dying")
			$CanvasLayer/DialogBox.start()
			yield($CanvasLayer/DialogBox, "dialogue_finished")
			SignalHandler.dialog_is_active = true
			$DeathAnim.play("death")
			yield($DeathAnim, "animation_finished")
			SignalHandler.boss_defeated_show_winscreen = true
			queue_free()


func _on_Hurtbox_area_exited(area):
	if area.name == "BossBarHide":
		set_boss_health_display(true)
	if area.name == "BuildingShow":
		set_display_over_building(false)

func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)

func available_good_guy(good_guys):
	for good_guy in good_guys:
		if !good_guy.is_sick and good_guy.get_node("ImmunityTimer").is_stopped():
			return true
	return false

func target_random():
	var n = get_tree().get_nodes_in_group("good_guys")
	if !available_good_guy(n):
		play_anim("Idle")
	rng.randomize()
	target = n[rng.randi_range(0, n.size()-1)]

func target_random_near():
#	rng.randomize()
#	if rng.randf()>0.9:
#		target_random()
#	else:
#		target_near()
	target_near()

func set_areas_disabled(val):
	hurtbox.set_deferred("disabled", val)
	hitbox.set_deferred("disabled", val)

func flash_red():
	for i in ["Body/Torso/Torso3","SpringySprites/Head3","SpringySprites/LeftEye3","SpringySprites/RightEye3","SpringySprites/LeftArm3","SpringySprites/RightArm3"]:
		var b = get_node(i)
		b.self_modulate = Color(1, 0, 0, 1)
		$WhiteFlash.interpolate_property(b, "self_modulate:a", null, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
	$WhiteFlash.start()

func flash_white():
	for i in ["Body/Torso/Torso3","SpringySprites/Head3","SpringySprites/LeftEye3","SpringySprites/RightEye3","SpringySprites/LeftArm3","SpringySprites/RightArm3"]:
		var b = get_node(i)
		b.self_modulate = Color(1, 1, 1, 1)
		$WhiteFlash.interpolate_property(b, "self_modulate:a", null, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3)
	$WhiteFlash.start()

func show_health_bar():
	$HealthBarTween.interpolate_property(health_bar, "rect_position:y", health_bar.rect_global_position.y+60, 
		health_bar.rect_global_position.y, 1.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$HealthBarTween.interpolate_property(health_bar, "self_modulate:a", 0, 1, 1.5,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	$HealthBarTween.start()

func set_boss_health_display(val):
	if val:
		health_bar.self_modulate.a = 1
	else:
		health_bar.self_modulate.a = 0.5
