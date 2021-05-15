extends Sprite

var velocity = Vector2(1000, 0)
var sc = 20

var rng = RandomNumberGenerator.new()

var NukeExplosion = preload("res://Weapons/ExplosionRed.tscn")

onready var hitbox = $RocketHitbox
var is_exploding = false

func _ready():
	set_z_index(0)
	$Tween.interpolate_property(self, "scale", Vector2.ZERO, Vector2(sc, sc), 0.2)
	$Tween.start()

func _physics_process(delta):
	position += velocity*delta

func _on_Despawn_timeout():
	queue_free()

func _on_RocketHitbox_area_entered(area):
	var explosion = NukeExplosion.instance()
	rng.randomize()
	explosion.position = $Position2D.global_position
	explosion.rotation_degrees = rng.randf_range(-180, 180)
	if is_exploding:
		return
	is_exploding = true
	get_tree().current_scene.call_deferred("add_child", explosion)
	queue_free()

func _process(_delta):
	if hitbox.get_overlapping_areas().size() > 0:
		var explosion = NukeExplosion.instance()
		rng.randomize()
		explosion.position = $Position2D.global_position
		explosion.rotation_degrees = rng.randf_range(-180, 180)
		if is_exploding:
			return
		is_exploding = true
		get_tree().current_scene.call_deferred("add_child", explosion)
		queue_free()

func _on_RocketHitbox_body_entered(body):
	if is_exploding:
		return
	var explosion = NukeExplosion.instance()
	rng.randomize()
	explosion.position = $Position2D.global_position
	explosion.rotation_degrees = rng.randf_range(-180, 180)
	get_tree().current_scene.call_deferred("add_child", explosion)
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
