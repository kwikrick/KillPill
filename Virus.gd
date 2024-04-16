extends RigidBody3D
var virus_death_scene = preload("res://virus_death.tscn")

const duplicate_time_min = 15
const duplicate_time_max = 45

# Called when the node enters the scene tree for the first time.
func _ready():
	$DuplicateTimer.wait_time = randf_range(duplicate_time_min,duplicate_time_max)
	$DuplicateTimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	apply_force(Vector3(randf_range(-100,100),randf_range(-100,100),randf_range(-100,100))) 
	
func _on_area_3d_body_entered(body:RigidBody3D):
	if body.damage:
		queue_free()
	var death = virus_death_scene.instantiate()
	death.global_position = global_position
	get_parent().add_child(death)

func _on_duplicate_timer_timeout():
	var main = get_tree().root.find_child("Main",true,false)
	if not main or not main.game_active: return
	
	var new_virus = duplicate()  # DUPLICATE_USE_INSTANTIATION
	new_virus.global_position = global_position
	get_parent().add_child(new_virus)
	$DuplicateTimer.wait_time = randf_range(duplicate_time_min,duplicate_time_max)
	$DuplicateTimer.start()
	$DuplicateAudioStreamPlayer3D.play()
	
