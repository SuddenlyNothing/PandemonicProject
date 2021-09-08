extends AnimatedSprite

func _ready():
	$AnimatedSprite.set_z_index(2)
	$AnimatedSprite.playing = true
	playing = true
	$Explode.play()

func _on_AnimatedSprite_animation_finished():
	queue_free()

func get_damage():
	return 3

func _on_AnimatedSprite_frame_changed():
	if frame == 3:
		$ExplosionHitbox/CollisionShape2D.disabled = false
	else:
		$ExplosionHitbox/CollisionShape2D.disabled = true
