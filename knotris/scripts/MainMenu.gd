extends Control

const TILE_TYPE_KEYS = Global.TILE_TYPE_KEYS
const TILE_TEXTURES = Global.TILE_TEXTURES

var knotris_colors = [
	Color(0.6117, 0.7490, 0.8901, 1),
	Color(1.0000, 0.6705, 0.2666, 1),
	Color(0.9176, 0.9294, 0.5098, 1),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set background to random knotris color
	randomize()
	var random_index = randi() % knotris_colors.size()
	VisualServer.set_default_clear_color(knotris_colors[random_index])
	
	# Set selectors to random tile textures
	var random_play_tile_index = randi() % TILE_TYPE_KEYS.size()
	var random_play_tile = TILE_TYPE_KEYS[random_play_tile_index]
	$PlayButton.get_node("LeftSelectorSprite").set_texture(TILE_TEXTURES[random_play_tile])
	$PlayButton.get_node("RightSelectorSprite").set_texture(TILE_TEXTURES[random_play_tile])
	
	var random_control_tile_index = randi() % TILE_TYPE_KEYS.size()
	var random_control_tile = TILE_TYPE_KEYS[random_control_tile_index]
	$ControlsButton.get_node("LeftSelectorSprite").set_texture(TILE_TEXTURES[random_control_tile])
	$ControlsButton.get_node("RightSelectorSprite").set_texture(TILE_TEXTURES[random_control_tile])
	
	# Set random title image
	var title_index = randi() % 4
	$Title.set_texture(load("res://assets/title_" + str(title_index) + ".png"))
	
	# Focus on play button
	$PlayButton.grab_focus()


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
