extends Sprite

var velocity = Vector2(100, 100)
var damage
var crit
var sc

func ready_vars(vel, rot, dam, scl, pos, c):
	crit = c
	velocity = vel
	velocity = velocity.rotated(rot)
	rotation_degrees = rad2deg(rot)
	damage = dam
	position = pos
	sc = scl

func _ready():
	$Tween.interpolate_property(self, "scale", Vector2.ZERO, Vector2(sc, sc), 0.2)
	$Tween.start()

func _physics_process(delta):
	position += velocity*delta

func get_damage_crit():
	return [damage,crit]

func _on_Despawn_timeout():
	queue_free()
