extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set background to white
	VisualServer.set_default_clear_color(Color(1, 1, 1, 1))


# On play start game of knotris 
func _on_PlayButton_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")


# On controls press open pop-up
func _on_ControlsButton_pressed():
	$ControlsPopup.visible = true