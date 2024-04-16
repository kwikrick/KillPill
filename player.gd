extends RigidBody3D
class_name Player

var main: Main = null

# enabled/disabled by main game flow
var input_enabled=true

# player ship movement
const rotate_speed = 10.0
const movement_speed = 100.0
const alignment_speed = 100.0

# mouse look
const mouse_look_speed = 0.001 
var mouse_look_global_dir = Vector3(0,0,-1)			# global look direction 

# shooting
var bullet_scn=preload("res://bullet.tscn")
var ready_to_fire=true
var bullit_speed=200

# Called when the node enters the scene tree for the first time.
func _ready():
	# always need a main, except when testing
	main = get_tree().root.find_child("Main",true,false)
	# for testing, enable mouse capture from start
	if not main:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# init mouse look direction
	mouse_look_global_dir = -1 * $Camera3D.global_basis.z
	

func _input(event):
	
	# for testing, esc disbales mouse capture 
	if not main and event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion: 
		# modify accumulated mouse rotation
		var sign = 1 if main and main.invert_y else -1 
		var delta_x = -1 * event.relative.x * mouse_look_speed
		var delta_y = sign * event.relative.y * mouse_look_speed
		mouse_look_global_dir = mouse_look_global_dir.rotated(global_basis.y ,delta_x).rotated(global_basis.x, delta_y)

func _process(_delta):
	if input_enabled:
		if Input.is_action_pressed("fire"):
			fire()
		
func _physics_process(delta):
	
	# set camera orientation (so camera will not rotate with ship)
	
	$Camera3D.look_at($Camera3D.global_position+mouse_look_global_dir, global_basis.y)
	
	# player movement ( add force to ship )
	
	if input_enabled:
		var move = Vector3(0,0,0)
		move.z += +movement_speed if Input.is_action_pressed("backwards") else 0
		move.z += -movement_speed if Input.is_action_pressed("forward") else 0
		move.x += +movement_speed if Input.is_action_pressed("right") else 0
		move.x += -movement_speed if Input.is_action_pressed("left") else 0
		move.y += +movement_speed if Input.is_action_pressed("up") else 0
		move.y += -movement_speed if Input.is_action_pressed("down") else 0
	
		apply_force(global_basis*move)
	
		var delta_roll = 0
		delta_roll += +rotate_speed  if  Input.is_action_pressed("roll_right") else 0.0
		delta_roll += -rotate_speed  if  Input.is_action_pressed("roll_left") else 0.0
		var delta_pitch = 0
		delta_pitch += +rotate_speed  if  Input.is_action_pressed("pitch_up") else 0.0
		delta_pitch += -rotate_speed  if  Input.is_action_pressed("pitch_down") else 0.0
		var delta_yaw= 0
		delta_yaw += +rotate_speed  if  Input.is_action_pressed("yaw_left") else 0.0
		delta_yaw += -rotate_speed  if  Input.is_action_pressed("yaw_right") else 0.0
		
		#var torque = Basis.IDENTITY.rotated(global_basis.y,delta_yaw).rotated(global_basis.x,delta_pitch).rotated(global_basis.z,delta_roll)
		apply_torque(global_basis.y * delta_yaw)
		apply_torque(global_basis.x * delta_pitch)
		apply_torque(global_basis.z * delta_roll)
	
		# ship align to camera
		
		var free_look = Input.is_action_pressed("free_look")
			
		if not free_look:
			
			var yaw_torque = global_basis.x.signed_angle_to($Camera3D.global_basis.x,global_basis.y)
			apply_torque(global_basis.y*yaw_torque*alignment_speed)
			
			var pitch_torque = global_basis.y.signed_angle_to($Camera3D.global_basis.y,global_basis.x)
			apply_torque(global_basis.x*pitch_torque*alignment_speed)
		

func fire():
	if ready_to_fire:
		ready_to_fire=false
		$FireReloadTimer.start()
		$FireAudioStreamPlayer.play()
		var bullet=bullet_scn.instantiate() as RigidBody3D
		bullet.global_position = $BulletSpawn.global_position
		bullet.linear_velocity=linear_velocity - global_basis.z * bullit_speed 
		get_parent().add_child(bullet)
		
		
func _on_fire_reload_timer_timeout():
	ready_to_fire=true
	


func _on_pain_timer_timeout():
	pass # Replace with function body.
