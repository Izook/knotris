extends Node2D

var tile = preload("res://scenes/Tile.tscn") 

# Constant board parameters
const BOARD_WIDTH = Global.BOARD_WIDTH
const BOARD_HEIGHT = Global.BOARD_HEIGHT
const OFFSET_X = Global.BOARD_OFFSET_X
const OFFSET_Y = Global.BOARD_OFFSET_Y

# Constant tile parameters
const TILE_KEYS = Global.TILE_TYPE_KEYS

# 2D matrix representing tiles placed on board
var tile_board = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate tile_board with empty values
	for i in range(BOARD_WIDTH):
		tile_board.append([])
		for j in range(BOARD_HEIGHT):
			tile_board[i].append(null)
	
	# Populate bottom row with internally suitably connected tiles
	for i in range(BOARD_WIDTH):
		tile_board[i][BOARD_HEIGHT - 1] = get_random_tile()
		if i > 0:
			var prev_tile = tile_board[i - 1][BOARD_HEIGHT - 1]
			var curr_tile = tile_board[i - 1][BOARD_HEIGHT - 1]
			while prev_tile.connection_points["right"] != curr_tile.connection_points["left"]:
				tile_board[i][BOARD_HEIGHT - 1] = get_random_tile()
		
	# Draw all tiles on board
	for i in range(BOARD_WIDTH):
		for j in range(BOARD_HEIGHT):
			if tile_board[i][j] != null:
				var x_pos = (i * Global.TILE_SIZE) + OFFSET_X
				var y_pos = (j * Global.TILE_SIZE) + OFFSET_Y
				tile_board[i][j].position = Vector2(x_pos, y_pos) 
				add_child(tile_board[i][j])

# Returns tile instantiated with random parameters
func get_random_tile():
	randomize()
	var new_tile = tile.instance()
	var random_type = TILE_KEYS[randi() % TILE_KEYS.size()]
	var random_rotation = randi() % 4
	new_tile.init(random_type, random_rotation)
	return new_tile