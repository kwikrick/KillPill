extends Node2D

var player:Player = null
var anim:AnimationPlayer = null

var game_active=false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/WinLabel.hide()
	$Control/LooseLabel.hide()
	$Control/RestartButton.hide()
	$Control/ResumeButton.hide()
	
	$Control/TitleTextureRect.show()
	$Control/ButtonStart.show()
	
	player = $World.find_child("Player",true,true)
	player.input_enabled = false
	anim = $World.find_child("AnimationPlayer",true,true) as AnimationPlayer
	anim.play("RESET")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var count = get_tree().get_nodes_in_group("virii").size()
	$Control/Panel/LabelViriiCount.text = "{0}".format([count])
	if game_active:
		if count == 0:
			win()
		elif count>=100:
			loose()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if game_active:
			game_active=false
			player.input_enabled=false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$Control/ResumeButton.show()
			$Control/RestartButton.show()
			
			
func _on_button_start_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Control/ButtonStart.hide()
	$Control/TitleTextureRect.hide()
	#player.input_enabled = true
	# TODO: move ship on rail
	anim.connect("animation_finished",_on_animation_finished)
	anim.play("FlyInto")
	
func _on_animation_finished(_anim_name):
	player.input_enabled=true
	game_active=true
	
func win():
	$Control/WinLabel.show()
	player.input_enabled=false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_active=false
	$Control/RestartButton.show()
	
func loose():
	$Control/LooseLabel.show()
	player.input_enabled=false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_active=false
	$Control/RestartButton.show()

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_resume_button_pressed():
	$Control/ResumeButton.hide()
	$Control/RestartButton.hide()
	game_active=true
	player.input_enabled=true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
