extends Control

# Global parameters
var TILE_SIZE = Global.TILE_SIZE
var BOARD_WIDTH = Global.BOARD_WIDTH

# Current game score
var score

# Current score multiplier
var multiplier

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set score to zero
	score = 0
	
	# Set multiplier to one
	multiplier = 1
	
	# Position / Size Score label appropriately
	$Score.rect_position = Vector2(TILE_SIZE * (BOARD_WIDTH + 4.5), 0)
	$Score.rect_size = Vector2(TILE_SIZE * 2, TILE_SIZE)
	
	# Set score text appropriately
	$Score.text = "SCORE: " + str(score)
	
	# Set PopUps to Show Above All Game Elements
	$PausedPopup.show_on_top = true
	$GameOverPopup.show_on_top = true


# Increments score and updates label
func increment_score(points):
	score += (points * multiplier)
	$Score.text = "SCORE: " + str(score) 


# Stops game and opens Game Over menu
func game_over():
	get_tree().paused = true
	$Score.visible = false
	$PausedPopup.visible = false
	$GameOverPopup/FinalScore.text = str(score)
	$GameOverPopup.visible = true


# Stops game and opens Pause menu
func pause():
	get_tree().paused = true
	$PausedPopup.visible = true


# Unpause and go back to main menu
func _on_ToMainMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")


# Unpause and reload scene to retry game
func _on_ReTry_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/Game.tscn")


func _on_UnPause_pressed():
	$PausedPopup.visible = false
	get_tree().paused = false


func _on_PauseButton_pressed():
	pause()


func _on_AudioButton_pressed():
	if Global.muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		$PausedPopup/AudioButton.set_normal_texture(load("res://assets/audio_off.png"))
		$PausedPopup.get_node("AudioButton").set_pressed_texture(load("res://assets/audio_off_pressed.png"))
		Global.muted = false
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		$PausedPopup/AudioButton.set_normal_texture(load("res://assets/audio_on.png"))
		$PausedPopup/AudioButton.set_pressed_texture(load("res://assets/audio_on_pressed.png"))
		Global.muted = true
