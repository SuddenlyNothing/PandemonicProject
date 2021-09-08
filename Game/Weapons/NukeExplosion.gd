extends AnimatedSprite

var damage
var crit

func _ready():
	set_z_index(0)
	$AnimatedSprite.set_z_index(2)
	$AnimatedSprite.playing = true
	playing = true
	$Explode.play()

func _on_AnimatedSprite_animation_finished():
	queue_free()

func set_volume(val):
	$Explode.volume_db = val

func get_damage():
	if crit:
		return 3
	else:
		return 1

func _on_AnimatedSprite_frame_changed():
	if frame == 3 or frame == 2:
		$ExplosionHitbox/CollisionShape2D.disabled = false
	else:
		$ExplosionHitbox/CollisionShape2D.disabled = true
