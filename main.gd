extends Node2D
class_name Main

var player:Player = null
var anim:AnimationPlayer = null

var game_active=false
var invert_y=false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()
	
	$Control/WinLabel.hide()
	$Control/LooseLabel.hide()
	$Control/RestartButton.hide()
	$Control/ResumeButton.hide()
	
	$Control/TitleTextureRect.show()
	$Control/ButtonStart.show()
	$Control/QuitButton.show()
	$Control/SettingsPanel.show()
	
	player = $World.find_child("Player",true,true)
	player.input_enabled = false
	anim = $World.find_child("AnimationPlayer",true,true) as AnimationPlayer
	anim.play("RESET")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var count = get_tree().get_nodes_in_group("virii").size()
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
			$Control/SettingsPanel.show()
			$Control/QuitButton.show()
			
			
func _on_button_start_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Control/ButtonStart.hide()
	$Control/QuitButton.hide()
	$Control/TitleTextureRect.hide()
	$Control/SettingsPanel.hide()
	#player.input_enabled = true
	# TODO: move ship on rail
	anim.connect("animation_finished",_on_animation_finished)
	anim.play("FlyInto")
	$AudioStreamPlayerIntro.stop()
	
func _on_animation_finished(_anim_name):
	player.input_enabled=true
	game_active=true
	
func win():
	$Control/WinLabel.show()
	player.input_enabled=false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_active=false
	$Control/RestartButton.show()
	$Control/QuitButton.show()
	$Control/SettingsPanel.show()
	
func loose():
	$Control/LooseLabel.show()
	player.input_enabled=false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_active=false
	$Control/RestartButton.show()
	$Control/QuitButton.show()
	$Control/SettingsPanel.show()

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_resume_button_pressed():
	$Control/ResumeButton.hide()
	$Control/RestartButton.hide()
	$Control/QuitButton.show()
	$Control/SettingsPanel.hide()
	game_active=true
	player.input_enabled=true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_button_fullscreen_toggled(toggled_on):
	if toggled_on:
		get_viewport().get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_viewport().get_window().mode = Window.MODE_WINDOWED
	save_settings()

func _on_check_button_invert_y_toggled(toggled_on):
	invert_y = toggled_on
	save_settings()

func _on_quit_button_pressed():
	#optional #get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "fullscreen", $Control/SettingsPanel/ButtonFullscreen.button_pressed)
	config.set_value("settings", "invert_y",  $Control/SettingsPanel/CheckButtonInvertY.button_pressed)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		return
	var fullscreen = type_convert(config.get_value("settings", "fullscreen"),TYPE_BOOL)
	var invert_y = type_convert(config.get_value("settings", "invert_y"),TYPE_BOOL)
	$Control/SettingsPanel/ButtonFullscreen.button_pressed = fullscreen
	$Control/SettingsPanel/CheckButtonInvertY.button_pressed = invert_y

