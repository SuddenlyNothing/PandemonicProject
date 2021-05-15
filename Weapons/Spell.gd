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
	var spell_particle = load("res://Weapons/SpellParticle.tscn").instance()
	var color_ramp = load("res://Weapons/SpellParticleColorRamp.tres")
	var color_gradient = load("res://Weapons/SpellParticleGradient.tres")
	var particlesMat = ParticlesMaterial.new()
	particlesMat.color_ramp = color_ramp
	particlesMat.set_trail_color_modifier(color_gradient)
	particlesMat.gravity = Vector3(0, 0, 0)
	particlesMat.emission_shape = 2
	particlesMat.scale = sc
#	particlesMat.trial_color_modifier = color_gradient
	spell_particle.process_material = particlesMat
	add_child(spell_particle)

func _physics_process(delta):
	position += velocity*delta

func get_damage_crit():
	return [damage,crit]

func _on_Despawn_timeout():
	queue_free()
