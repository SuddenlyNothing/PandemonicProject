extends Node2D

onready var body : Node2D = $Body

onready var player : KinematicBody2D = $"../Player"
onready var nav_2d : Navigation2D = $"../Navigation2D"
onready var line2d : Line2D = $Line2D
onready var avoid_wall_timer : Timer = $AvoidWall

enum {
	IDLE,
	WANDER,
	SEARCH,
	ATTACK
}

var speed := 100
var path
var attack_range = 5

var state

func _physics_process(delta:float):
#	if is_on_wall():
#		avoid_wall_timer.start()
#		print("bad")
#		path = nav_2d.get_simple_path(position, player.position, false)
#	elif !avoid_wall_timer.is_stopped():
#		path = nav_2d.get_simple_path(position, player.position, false)
#	else:
	path = nav_2d.get_simple_path(position, player.position)
	var move_distance := speed*delta
	set_line2d()
	move_along_path(move_distance, delta)

func set_line2d():
	line2d.set_default_color(Color(0.4, 0.5, 1, 1))
	var line_path := PoolVector2Array()
	for i in path:
		line_path.append(to_local(i))
	line2d.points = line_path

func move_along_path(distance: float, delta) -> void:
	var start_point := position
	for i in range(path.size()):
		set_facing_right()
		# uses how far we move during the process to move on the path towards the player
		var distance_to_next : = start_point.distance_to(path[0])
		if distance_to_next == 0:
			path.remove(0)
			continue
		if distance <= distance_to_next:
			# go towards the player
			var endpoint = start_point.linear_interpolate(path[0], distance/distance_to_next)
			var move_rot = Vector2(endpoint-start_point).angle()
			var motion = Vector2(speed, 0).rotated(move_rot)
			position+=motion*delta
			break
		elif path.size() == 1:
			# go to the final point
			position+=(path[0]-start_point)*delta
#			print('move_along_path broke')
			break
		# moves past this point and prepares to move towards the next
		distance -= distance_to_next
		start_point = path[0]+Vector2(1, 19)
		path.remove(0)

func set_facing_right():
	if player.global_position.x > position.x:
		body.scale.x = 1
	else:
		body.scale.x = -1
