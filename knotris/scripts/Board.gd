extends Node2D

# Constant board parameters
const BOARD_WIDTH = Global.BOARD_WIDTH
const BOARD_HEIGHT = Global.BOARD_HEIGHT

# 2D matrix representing tiles placed on board
var tileBoard = [[0]]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate tileBoard with empty values
	for i in range(BOARD_WIDTH):
		tileBoard.append([])
		for j in range(BOARD_HEIGHT):
			tileBoard[i].append(null)
	
	# TODO: Populate bottom row with internally suitably connected tiles
