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
const TILE_SIZE = Global.TILE_SIZE

# 2D matrix representing tiles placed on board
var tile_board = [] setget , get_tile_board

# Node representing the player
var curr_player

# Reference to tile_bag sibling node
var tile_bag

# Reference to HUD sibling node
var hud


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Populate tile_bag + hud reference
	tile_bag = get_parent().get_node("TileBag")
	hud = get_parent().get_node("HUD")
		
	# Populate tile_board with empty values
	for i in range(BOARD_WIDTH):
		tile_board.append([])
		for j in range(BOARD_HEIGHT):
			tile_board[i].append(null)
	
	# Populate bottom row with internally suitably connected tiles
	for i in range(BOARD_WIDTH):
		if i > 0:
			var prev_tile = tile_board[i - 1][BOARD_HEIGHT - 1]
			tile_board[i][BOARD_HEIGHT - 1] = get_random_connected_tile(prev_tile.connection_points[1])
		else:
			tile_board[i][BOARD_HEIGHT - 1] = get_random_tile()

		
	# Draw all tiles on board
	for i in range(BOARD_WIDTH):
		for j in range(BOARD_HEIGHT):
			if tile_board[i][j] != null:
				add_child(tile_board[i][j])
				_draw_tile(i, j)
	
	# Add the Player to the board
	curr_player = player.instance()
	add_child(curr_player)


# Draw specified tile on at correct position on board
func _draw_tile(x_coord, y_coord):
	if tile_board[x_coord][y_coord] != null:
		var x_pos = (x_coord * TILE_SIZE) + OFFSET_X
		var y_pos = (y_coord * TILE_SIZE) + OFFSET_Y
		tile_board[x_coord][y_coord].position = Vector2(x_pos, y_pos) 


# Returns tile instantiated with random parameters
func get_random_tile():
	randomize()
	
	var random_type = TILE_KEYS[randi() % TILE_KEYS.size()]
	var random_rotation = randi() % 4
	
	var random_tile = tile.instance()
	random_tile.init(random_type, random_rotation)
	
	return random_tile


# Returns tile instantiated with random parameters connected to the left
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


# Adds new tile to the board at a declared position
func add_tile(tile, tile_pos):
	if (tile_board[tile_pos.x][tile_pos.y] == null):
		tile_board[tile_pos.x][tile_pos.y] = tile
	else:
		print("Illegal tile addition attempted.")
		tile.queue_free()


# Returns tile board
func get_tile_board():
	return tile_board


# Clear a row that is internally and externally suitably connected and moves 
# all other rows down appropriately. Also sends values of row to be cleared
# to HUD to increment score.
func _clear_row(row_index):
	var row_value = 0
	for j in range(row_index, 0, -1):
		var empty_row = true
		for i in range(BOARD_WIDTH):
			
			# Remove tile from board if from cleared row
			if j == row_index:
				row_value += tile_board[i][j].tile_score
				tile_board[i][j].queue_free()
				tile_board[i][j] = null
			
			# Move tiles down
			var above_tile = null
			if j > 0:
				above_tile = tile_board[i][j - 1]
			tile_board[i][j] = above_tile
			_draw_tile(i, j)
			
			# Only continue if row isn't empty 
			if above_tile != null:
				empty_row = false
		if empty_row:
			break
	hud.increment_score(row_value)


# Checks rows for internal and external suitable connectedness
# Returns false if row was cleared, true if no rows can be cleared
func check_rows():
	for j in range(BOARD_HEIGHT - 1, -1, -1):
		var empty_row = false
		var should_clear = true
		for i in range(BOARD_WIDTH):
			var curr_tile = tile_board[i][j]
			
			# Is row non empty?
			if curr_tile == null: 
				empty_row = true
				break
				
			# Is row externally suitably connected?
			var above_tile = tile_board[i][j - 1]
			if above_tile == null || curr_tile.connection_points[0] != above_tile.connection_points[2]:
				should_clear = false
				break
				
			# Is row internally suitably connected?
			if i < BOARD_WIDTH - 1:
				var right_tile = tile_board[i + 1][j]
				if right_tile == null || curr_tile.connection_points[1] != right_tile.connection_points[3]:
					should_clear = false;
					break
		if empty_row:
			break
		if should_clear:
			_clear_row(j)
			return 1 + check_rows()
	return 0