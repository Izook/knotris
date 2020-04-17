extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set background to white
	VisualServer.set_default_clear_color(Color(0.7, 0.7, 0.7, 1))

# On play start game of knotris 
func _on_PlayButton_pressed():
	$StartSound.play()
	yield($StartSound, "finished")
	get_tree().change_scene("res://scenes/Game.tscn")


# On controls press open pop-up
func _on_ControlsButton_pressed():
	$MenuSound.play()
	$ControlsPopup.visible = true


func _on_AudioButton_pressed():
	if Global.muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		$AudioButton.set_normal_texture(load("res://assets/AudioOffIcon.png"))
		Global.muted = false
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		$AudioButton.set_normal_texture(load("res://assets/AudioOnIcon.png"))
		Global.muted = true
