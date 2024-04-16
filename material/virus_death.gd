extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CPUParticles3D.emitting=true

func _on_cpu_particles_3d_finished():
	queue_free()
