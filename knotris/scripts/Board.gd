extends Node2D

var tile = preload("res://scenes/Tile.tscn")
var player = preload("res://scenes/Player.tscn") 

# Constant board parameters
const BOARD_WIDTH = Global.BOARD_WIDTH
const BOARD_HEIGHT = Global.BOARD_HEIGHT
const OFFSET_X = Global.BOARD_OFFSET_X
const OFFSET_Y = Global.BOARD_OFFSET_Y

# Constant tile parameters
const TILE_KEYS = Global.TILE_TYPE_KEYS
const LEFT_CONN_TILE_COMBOS = Global.left_connected_combinations
const LEFT_DISCONN_TILE_COMBOS = Global.left_disconnected_combinations

# 2D matrix representing tiles placed on board
var tile_board = []

# Node representing the player
var curr_player;


# Called when the node enters the scene tree for the first time.
func _ready():
		
	# Populate tile_board with empty values
	for i in range(BOARD_WIDTH):
		tile_board.append([])
		for j in range(BOARD_HEIGHT):
			tile_board[i].append(null)
	
	# Populate bottom row with internally suitably connected tiles
	for i in range(BOARD_WIDTH):
		if i > 0:
			var prev_tile = tile_board[i - 1][BOARD_HEIGHT - 1]
			tile_board[i][BOARD_HEIGHT - 1] = get_random_connected_tile(prev_tile.connection_points["right"])
		else:
			tile_board[i][BOARD_HEIGHT - 1] = get_random_tile()

		
	# Draw all tiles on board
	for i in range(BOARD_WIDTH):
		for j in range(BOARD_HEIGHT):
			if tile_board[i][j] != null:
				var x_pos = (i * Global.TILE_SIZE) + OFFSET_X
				var y_pos = (j * Global.TILE_SIZE) + OFFSET_Y
				tile_board[i][j].position = Vector2(x_pos, y_pos) 
				add_child(tile_board[i][j])
	
	# Add the Player to the board
	curr_player = player.instance()
	add_child(curr_player)


# Returns tile instantiated with random parameters
func get_random_tile():
	randomize()
	var new_tile = tile.instance()
	var random_type = TILE_KEYS[randi() % TILE_KEYS.size()]
	var random_rotation = randi() % 4
	new_tile.init(random_type, random_rotation)
	return new_tile


# Returns tile instantiated with random parameters
func get_random_connected_tile(left_connected):
	randomize()
	var random_index
	var random_combo
	if left_connected:
		random_index = randi() % LEFT_CONN_TILE_COMBOS.size()
		random_combo = LEFT_CONN_TILE_COMBOS[random_index]
	else:
		random_index = randi() % LEFT_DISCONN_TILE_COMBOS.size()
		random_combo = LEFT_DISCONN_TILE_COMBOS[random_index]
	var new_tile = tile.instance()
	var random_type = random_combo[0]
	var random_rotation = random_combo[1]
	new_tile.init(random_type, random_rotation)
	return new_tile
