extends Node2D

onready var body : Node2D = $Body

onready var nav_2d : Navigation2D = $"../../../Navigation2D"
onready var line2d : Line2D = $Line2D
onready var move_pos := $MoveTo
onready var wander_wait_timer := $WanderWait
onready var wander_stuck_timer := $WanderStuck
onready var anim_player = $AnimationPlayer
onready var sick_player = $Sick

onready var hbox := $Hurtbox/CollisionShape2D

var Bad_Guy

var is_sick = false
var is_not_immune = false

enum {
	WANDER,
	GET_SICK,
}

var wander_speed := 80
var wander_x_bound = 2048
var wander_y_bound = 2048

var path
var avoid_move_vector = Vector2()
var avoid_areas = []

var rng = RandomNumberGenerator.new()

var state

func _ready():
	if Bad_Guy == null:
		Bad_Guy = load("res://Charecters/BadGuy.tscn")
	if is_not_immune or SignalHandler.boss:
		$ImmunityTimer.start(0.01)
	SignalHandler.change_num_good_guys(1)
	rng.randomize()
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.seek(rng.randf_range(0,1))
	_set_state(WANDER)

func _set_state(new_state):
	if state != null:
		_exit_state(new_state)
	else:
		_enter_state(new_state)

func _exit_state(new_state):
	match state:
		WANDER:
			wander_stuck_timer.stop()
		GET_SICK:
			return
	_enter_state(new_state)

func _enter_state(new_state):
	match new_state:
		WANDER:
			randomize_move_pos()
			wander_stuck_timer.start()
		GET_SICK:
			SignalHandler.getting_sick += 1
			is_sick = true
			hbox.set_deferred("disabled", true)
			sick_player.play("Get_sick")
			$Tween.interpolate_property(anim_player, "playback_speed", 3, 0, 2)
			$Tween.start()
	state = new_state

func _physics_process(delta:float):
	match state:
		GET_SICK:
			pass
		WANDER:
			if abs(move_pos.position.x)>wander_x_bound or abs(move_pos.position.y)>wander_y_bound:
				return
			if position.distance_to(move_pos.position) < 5:
				randomize_move_pos()
			if avoid_areas.size() == 0:
				path = nav_2d.get_simple_path(position, move_pos.position)
				var move_distance := wander_speed*delta
				set_line2d()
				move_along_path(move_distance, delta)
			else:
				path = nav_2d.get_simple_path(position, move_pos.position)
				var move_distance := wander_speed/6*delta
				set_line2d()
				move_along_path(move_distance, delta)
				var avoid_pos = avoid_areas[0].global_position
				if abs(position.x-avoid_pos.x) < 0 and abs(position.y-avoid_pos.y) <0:
					rng.randomize()
					position += Vector2.RIGHT.rotated(deg2rad(rng.randf_range(0, 359)))*wander_speed/6*delta*5
				else:
					position += (position-avoid_pos).normalized()*wander_speed/4*delta*3

func randomize_move_pos():
	move_pos.position = Vector2(wander_x_bound*2, wander_y_bound*2)
	rng.randomize()
	wander_wait_timer.wait_time = rng.randf_range(0.5, 2)
	wander_wait_timer.start()
	yield(wander_wait_timer, "timeout")
	rng.randomize()
	move_pos.position = Vector2(rng.randf_range(-wander_x_bound, wander_x_bound), rng.randf_range(-wander_y_bound, wander_y_bound))

func set_line2d():
	line2d.set_default_color(Color(0.4, 0.5, 1, 1))
	var line_path := PoolVector2Array()
	for i in path:
		line_path.append(to_local(i))
	line2d.points = line_path

func move_along_path(distance: float, delta) -> void:
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
			var motion = Vector2(wander_speed, 0).rotated(move_rot)
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
		start_point = path[0]+Vector2(1, 19)
		path.remove(0)

func set_facing_right(t_pos):
	if t_pos.x > position.x:
		body.scale.x = 1
	else:
		body.scale.x = -1

func _on_Hurtbox_area_entered(area):
	if area.name == "BuildingShow":
		set_display_over_building(true)
	if area.name == "Hurtbox":
		avoid_areas.append(area)
	if area.name == "Hitbox":
		if area.get_parent().get_parent().name == "Boss":
			rng.randomize()
			match rng.randi_range(0, 3):
				0:
					Bad_Guy = load("res://Charecters/BadGuy.tscn")
				1:
					Bad_Guy = load("res://Charecters/BadGuyCamo.tscn")
				2:
					Bad_Guy = load("res://Charecters/BadGuyFast.tscn")
				3:
					Bad_Guy = load("res://Charecters/BadGuyWeak.tscn")
		else:
			Bad_Guy = load(area.get_parent().get_parent().filename)
		_set_state(GET_SICK)

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

func _on_Sick_animation_finished(anim_name):
	var bad_guy = Bad_Guy.instance()
	bad_guy.position = position
	get_parent().add_child(bad_guy)
	SignalHandler.change_num_good_guys(-1)
	SignalHandler.getting_sick -= 1
	queue_free()

func set_display_over_building(val):
	for i in ["Body/Torso/Torso","SpringySprites/Head","SpringySprites/LeftEye","SpringySprites/RightEye","SpringySprites/LeftArm","SpringySprites/RightArm"]:
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

func _on_ImmunityTimer_timeout():
	$Hurtbox/CollisionShape2D.disabled = false
