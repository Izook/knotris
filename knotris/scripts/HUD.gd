extends Node2D

# Global parameters
const TILE_SIZE = Global.TILE_SIZE
const BOARD_WIDTH = Global.BOARD_WIDTH

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
	$Score.rect_position = Vector2(TILE_SIZE * (BOARD_WIDTH + 5), TILE_SIZE*0.5)
	$Score.rect_size = Vector2(TILE_SIZE, TILE_SIZE)
	
	# Set score text appropriately
	$Score.text = "SCORE: " + score as String 


# Increments score and updates label
func increment_score(points):
	score += (points * multiplier)
	$Score.text = "SCORE: " + score as String 