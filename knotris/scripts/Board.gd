extends Node2D

var tile = preload("res://scenes/Tile.tscn") 

# Constant board parameters
const BOARD_WIDTH = Global.BOARD_WIDTH
const BOARD_HEIGHT = Global.BOARD_HEIGHT
const OFFSET_X = Global.BOARD_OFFSET_X
const OFFSET_Y = Global.BOARD_OFFSET_Y

# 2D matrix representing tiles placed on board
var tileBoard = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate tileBoard with empty values
	for i in range(BOARD_WIDTH):
		tileBoard.append([])
		for j in range(BOARD_HEIGHT):
			tileBoard[i].append(null)
	
	# TODO: Populate bottom row with internally suitably connected tiles
	for i in range(BOARD_WIDTH):
		var new_tile = tile.instance()
		new_tile.init("B", 2)
		tileBoard[i][BOARD_HEIGHT - 1] = new_tile
		
	# Draw all tiles on board
	for i in range(BOARD_WIDTH):
		for j in range(BOARD_HEIGHT):
			if tileBoard[i][j] != null:
				var x_pos = (i * Global.TILE_SIZE) + OFFSET_X
				var y_pos = (j * Global.TILE_SIZE) + OFFSET_Y
				tileBoard[i][j].position = Vector2(x_pos, y_pos) 
				add_child(tileBoard[i][j])
