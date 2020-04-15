extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set background to white
	VisualServer.set_default_clear_color(Color(1, 1, 1, 1))
	
	# Mute game if running on HTML iOS Export
	if OS.get_name() == "iOS":
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)


# On play start game of knotris 
func _on_PlayButton_pressed():
	$StartSound.play()
	yield($StartSound, "finished")
	get_tree().change_scene("res://scenes/Game.tscn")


# On controls press open pop-up
func _on_ControlsButton_pressed():
	$MenuSound.play()
	$ControlsPopup.visible = true
