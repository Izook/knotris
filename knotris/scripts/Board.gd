extends Node2D

# Constant board parameters
const BOARD_WIDTH = 6
const BOARD_HEIGHT = 13

# 2D Array representing tiles placed on board
var tileBoard = [[0]]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate tileBoard with empty values
	for i in range(BOARD_WIDTH):
		tileBoard.append([])
		for j in range(BOARD_HEIGHT):
			tileBoard[i].append(null)
	
	# TODO: Populate bottom row with internally suitably connected tiles
