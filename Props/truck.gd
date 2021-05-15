extends Sprite

onready var open = $CarOpen
onready var close = $CarClose
onready var start = $CarStart
onready var stop = $CarStop
onready var drive = $CarDrive
onready var rev = $CarRev

onready var wheel_anim = $WheelAnim
onready var bounce_anim = $BounceAnim
onready var bt = $BounceTween
onready var vt = $VolumeTween

signal started
signal stopped

signal door_opened
signal door_closed

func drive():
	if !vt.is_active():
		drive.volume_db = 10
	drive.play()
	wheel_anim.playback_speed = 2
	wheel_anim.play("wheels")
	bounce_anim.play("bounce")

func start_car():
	start.play()
	bounce_anim.play("bounce")
	bt.interpolate_property(bounce_anim, "playback_speed", 0, 1, 2)
	bt.start()
	yield(start, "finished")
	emit_signal("started")
	drive.play()
	rev.play()
	$Tween.interpolate_property(wheel_anim, "playback_speed", 0, 2, 2)
	$Tween.interpolate_property(drive, "volume_db", 0, 10, 2)
	$Tween.start()
	wheel_anim.play("wheels")
	yield(rev, "finished")

func stop_car():
	$Tween.interpolate_property(wheel_anim, "playback_speed", 2, 0, 2, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(drive, "volume_db", 10, 0, 2)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	drive.stop()
	stop.play()
	bt.interpolate_property(bounce_anim, "playback_speed", 1, 0, 2, Tween.TRANS_EXPO, Tween.EASE_IN)
	bt.start()
	yield(stop, "finished")
	emit_signal("stopped")

func open_close_door():
	open_door(true)

func open_door(close=false):
	open.play()
	if close:
		yield(open, "finished")
		$CloseDoor.start()
		emit_signal("door_opened")
		yield($CloseDoor, "timeout")
		close_door()

func close_door():
	close.play()
	yield(close, "finished")
	emit_signal("door_closed")

func quiet(val):
	vt.interpolate_property(drive, "volume_db", 10, -30, val)
	vt.start()

func loud(val):
	vt.interpolate_property(drive, "volume_db", -10, 10, val)
	vt.start()
