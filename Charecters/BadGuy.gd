extends Node2D

onready var body : Node2D = $Body

onready var nav_2d : Navigation2D = $"../../../Navigation2D"
onready var line2d : Line2D = $Line2D
onready var move_pos := $MoveTo
onready var wander_wait_timer := $WanderWait
onready var wander_stuck_timer := $WanderStuck
onready var cough_sneeze_timer := $CoughSneeze

onready var detect_circle := $Areas/DetectTarget/CollisionShape2D
onready var detect_poly := $Areas/DetectTarget/CollisionPolygon2D

onready var health_bar = $Body/Torso/ProgressBar/ProgressBar
onready var node_health_bar = $Body/Torso/ProgressBar

onready var chase_delay = $ChaseDelay

onready var Good_Guy := load("res://Charecters/GoodGuy.tscn")

export var weak = false
export var camo = false
export var chase_delay_wait_time = 2

enum {
	WANDER,
	CHASE,
	GET_HEALTHY
}

export var wander_speed := 100
var wander_x_bound = 2048
var wander_y_bound = 2048
export var do_chase_delay = true

export var chase_speed := 150
var target
var path
var avoid_move_vector = Vector2()
var avoid_areas = []

var summoning = false

var rng = RandomNumberGenerator.new()

var state

var boss_defeated_timer_started = false

func _ready():
	match SignalHandler.difficulty:
		"easy":
			chase_delay_wait_time = 100
		"medium":
			chase_delay_wait_time = 4
		"hard":
			chase_delay_wait_time = 2
	chase_delay.wait_time = chase_delay_wait_time
	if !do_chase_delay:
		chase_delay.wait_time = 0.1
	chase_delay.start()
	if weak:
		health_bar.visible = false
		health_bar.value = 0.5
	rng.randomize()
	cough_sneeze_timer.start(rng.randf_range(1, 2))
	SignalHandler.change_num_bad_guys(1)
	rng.randomize()
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.seek(rng.randf_range(0,1))
	_set_state(WANDER)

func change_difficulty(dif):
	match SignalHandler.difficulty:
		"easy":
			chase_delay_wait_time = 100
		"medium":
			chase_delay_wait_time = 4
		"hard":
			chase_delay_wait_time = 2

func _set_state(new_state):
	if state != null:
		_exit_state(new_state)
	else:
		_enter_state(new_state)

func _exit_state(new_state):
	match state:
		WANDER:
			wander_stuck_timer.stop()
			detect_circle.set_deferred("disabled", true)
			detect_poly.set_deferred("disabled", true)
		CHASE:
			pass
		GET_HEALTHY:
			return
	_enter_state(new_state)

func _enter_state(new_state):
	match new_state:
		WANDER:
			chase_delay.start()
			randomize_move_pos()
			wander_stuck_timer.start()
			$AnimationPlayer.play("Idle")
		CHASE:
			detect_poly.set_deferred("disabled", true)
			detect_circle.set_deferred("disabled", true)
			$AnimationPlayer.play("Run")
		GET_HEALTHY:
			$Areas/Hitbox/CollisionShape2D.set_deferred("disabled", true)
			$Areas/Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$AnimationPlayer.play("Idle")
			$GetHealthy.play("Heal")
	state = new_state

func _physics_process(delta:float):
	if SignalHandler.boss_defeated:
		if !boss_defeated_timer_started:
			boss_defeated_timer_started = true
			rng.randomize()
			$BossDefeated.start(rng.randf_range(1, 3))
		return
	if summoning:
		return
	match state:
		CHASE:
			if target == null or target.is_sick:
				_set_state(WANDER)
				return
			if avoid_areas.size()==0:
				path = nav_2d.get_simple_path(position, target.position)
				var move_distance := chase_speed*delta
				set_line2d()
				move_along_path(move_distance, delta, chase_speed)
			else:
				path = nav_2d.get_simple_path(position, target.position)
				var move_distance := chase_speed/6*delta
				set_line2d()
				move_along_path(move_distance, delta, chase_speed)
				var avoid_pos = avoid_areas[0].global_position
				if abs(position.x-avoid_pos.x) < 0 and abs(position.y-avoid_pos.y) <0:
					rng.randomize()
					position += Vector2.RIGHT.rotated(deg2rad(rng.randf_range(0, 359)))*chase_speed/6*delta*5
				else:
					position += (position-avoid_pos).normalized()*chase_speed/4*delta*3
		WANDER:
			if path == null:
				return
			if abs(move_pos.position.x)>wander_x_bound or abs(move_pos.position.y)>wander_y_bound:
				return
			if !wander_wait_timer.is_stopped():
				return
			
			if position.distance_to(move_pos.position) < 5:
				randomize_move_pos()
			set_line2d()
			if path[path.size()-1] != move_pos.position:
				randomize_move_pos(true)
				return
			if avoid_areas.size() == 0:
				var move_distance := wander_speed*delta
				move_along_path(move_distance, delta, wander_speed)
			else:
				var move_distance := wander_speed/6*delta
				move_along_path(move_distance, delta, wander_speed)
				var avoid_pos = avoid_areas[0].global_position
				if abs(position.x-avoid_pos.x) < 0 and abs(position.y-avoid_pos.y) <0:
					rng.randomize()
					position += Vector2.RIGHT.rotated(deg2rad(rng.randf_range(0, 359)))*wander_speed/6*delta*5
				else:
					position += (position-avoid_pos).normalized()*wander_speed/4*delta*3

func randomize_move_pos(instant=false):
	if !wander_wait_timer.is_stopped():
		return
	
	if !instant:
		wander_wait_timer.wait_time = rng.randf_range(0.5, 2)
		wander_wait_timer.start()
		yield(wander_wait_timer, "timeout")
	
	if path == null:
		path = PoolVector2Array([Vector2.ONE*wander_x_bound*2])
	
	rng.randomize()
	move_pos.position = Vector2(rng.randf_range(-wander_x_bound, wander_x_bound), rng.randf_range(-wander_y_bound, wander_y_bound))
	path = nav_2d.get_simple_path(position, move_pos.position)
	
	while move_pos.position != path[path.size()-1]:
		rng.randomize()
		move_pos.position = Vector2(rng.randf_range(-wander_x_bound, wander_x_bound), rng.randf_range(-wander_y_bound, wander_y_bound))
		path = nav_2d.get_simple_path(position, move_pos.position)

func set_line2d():
	if path == null:
		return
	line2d.set_default_color(Color(0.4, 0.5, 1, 1))
	var line_path := PoolVector2Array()
	line_path.append(Vector2(0,0))
	for i in path:
		line_path.append(to_local(i))
	line2d.points = line_path

func move_along_path(distance: float, delta, speed) -> void:
	var start_point := position
	for i in range(path.size()):
		set_facing_right(path[0])
		set_view_dir(path[0])
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
			if state == WANDER:
				randomize_move_pos()
			break
		# moves past this point and prepares to move towards the next
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func set_facing_right(t_pos):
	if t_pos.x > position.x:
		if body.scale.x < 0:
			body.scale.x*= -1
	else:
		if body.scale.x > 0:
			body.scale.x*= -1

func _on_Hurtbox_area_entered(area):
	if area.name == "BuildingShow":
		set_display_over_building(true)
	if area.name == "Hurtbox":
		avoid_areas.append(area)
	elif area.name == "ExplosionHitbox":
		if SignalHandler.boss:
			return
		health_bar.value -= area.get_parent().get_damage()

func _on_Hurtbox_area_exited(area):
	if area.name == "BuildingShow":
		set_display_over_building(false)
	if area.name == "Hurtbox":
		if avoid_areas.size() > 0:
			var index = 0
			for i in avoid_areas:
				if i == area:
					break
				index += 1
			avoid_areas.remove(index)

var stuck_prevention_pos
func _on_WanderStuck_timeout():
	if !wander_wait_timer.is_stopped():
		return
	if stuck_prevention_pos != null and position.distance_to(stuck_prevention_pos) < 5:
		randomize_move_pos()
	stuck_prevention_pos = position

func _on_DetectTarget_area_entered(area):
	if state == GET_HEALTHY or !chase_delay.is_stopped():
		return
	var parent = area.get_parent()
	target = parent
	_set_state(CHASE)

func _on_Hitbox_area_entered(area):
	_set_state(WANDER)

func _on_GetHealthy_animation_finished(anim_name):
	var good_guy = Good_Guy.instance()
	good_guy.position = position
	get_parent().add_child(good_guy)
	SignalHandler.change_num_bad_guys(-1)
	queue_free()

func _on_ProgressBar_value_changed(value):
	if value == 0:
		_set_state(GET_HEALTHY)
	else:
		if weak:
			return
		flash_white()
		if !weak and !node_health_bar.visible:
			node_health_bar.visible = true

func set_display_over_building(val):
	if $Areas/Hitbox/CollisionShape2D.disabled:
		return
	for i in ["Body/Torso/Torso","SpringySprites/Head","SpringySprites/LeftEye","SpringySprites/RightEye","SpringySprites/LeftArm","SpringySprites/RightArm","Body/Torso/ProgressBar"]:
		if val:
			get_node(i).z_index = -1
		else:
			get_node(i).z_index = 0
	$Body/Torso/Torso2.visible = val
	$SpringySprites/Head2.visible = val
	$SpringySprites/LeftEye2.visible = val
	$SpringySprites/RightEye2.visible = val
	$SpringySprites/LeftArm2.visible = val
	$SpringySprites/RightArm2.visible = val

func _on_CoughSneeze_timeout():
	rng.randomize()
	if camo:
		cough_sneeze_timer.start(rng.randf_range(0, 1.5))
	else:
		cough_sneeze_timer.start(rng.randf_range(3, 9))
	
	var sound = rng.randi_range(0, 2)
	flash_red()
	match sound:
		0:
			$Sounds/Cough.pitch_scale = rng.randf_range(0.7, 1.3)
			$Sounds/Cough.play()
		1:
			$Sounds/CoughCough.pitch_scale = rng.randf_range(0.7, 1.3)
			$Sounds/CoughCough.play()
		2:
			$Sounds/Sneeze.pitch_scale = rng.randf_range(0.7, 1.3)
			$Sounds/Sneeze.play()

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

func set_view_dir(pos):
	detect_poly.rotation_degrees = rad2deg((pos-position).angle())

func _on_ChaseDelay_timeout():
	detect_circle.set_deferred("disabled", false)
	detect_poly.set_deferred("disabled", false)

func _on_BossDefeated_timeout():
	_set_state(GET_HEALTHY)
