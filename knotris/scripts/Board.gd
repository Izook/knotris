extends Node2D

const Tile = preload("res://scenes/Tile.tscn")
const Player = preload("res://scenes/Player.tscn") 

# Constant board parameters
var BOARD_WIDTH = Global.BOARD_WIDTH
var BOARD_HEIGHT = Global.BOARD_HEIGHT
var OFFSET_X = Global.BOARD_OFFSET_X
var OFFSET_Y = Global.BOARD_OFFSET_Y

# Constant tile parameters
var TILE_KEYS = Global.TILE_TYPE_KEYS
var LEFT_CONN_TILE_COMBOS = Global.left_connected_combinations
var LEFT_DISCONN_TILE_COMBOS = Global.left_disconnected_combinations
var TILE_SIZE = Global.TILE_SIZE

# 2D matrix, in the form [x][y], representing tiles placed on board.
# [0][0] represents the bottom left of the board
var tile_board = [] setget , get_tile_board

# Node representing the player
var curr_player

# Current level of difficulty
var level = 1

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
	curr_player = Player.instance()
	add_child(curr_player)
	
	# Start background music
	$BackgroundMusic.play()


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
	
	var random_tile = Tile.instance()
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
	var new_tile = Tile.instance()
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


# Performs a DFS starting from the tile_pos in order to detect any 
# knots or links that may be on the board. If any links are found 
# increment the multiplier of all tiles associated with that link.
func detect_knots(tile_pos):
	var starting_tile = tile_board[tile_pos.x][tile_pos.y]
	
	# Stack of tiles to be searched with the entry point used to traverse 
	# to them. Form {tile_pos: [tile_pos], entry_point: [edge]}
	var tile_stack = []
	
	# Map of tiles searched in the form:
	# <tile, {tile_pos: prev_tile_pos, entry_point: [edge]}> with entry point 
	# refering to the entry point used to enter the key tile.
	var tiles_searched = {}
	
	# Add all the tiles connected to the starting tile to the stack
	for i in range(4):
		
		# Check if connected
		if starting_tile.connection_points[i]:
			var connected_tile_vector = Tile.get_edge_vector(i)
			var connected_tile_pos = tile_pos + connected_tile_vector
			
			# Check if tile is placed there
			if _is_tile_at(connected_tile_pos):
				var entry_edge = Tile.get_edge_vector(Tile.get_opposite_edge())
				tile_stack.push_front({ "tile_pos": connected_tile_pos, "entry_point": entry_edge})
				#tiles_searched[connected_tile] = starting_tile
	
	# Add starting tile to list of visited tiles
	tiles_searched[starting_tile] = null
	
	# Go through all tiles in the stack until stack is empty
	while tile_stack.size() > 0:
		
		# Get tile connected to this tile
		var curr_tile_data = tile_stack.pop_front()
		var curr_tile_pos = curr_tile_data.tile_pos
		var curr_tile_entry_point = curr_tile_data.entry_point
		var connected_tile_data = _get_connected_tile(curr_tile_pos, curr_tile_entry_point)
		var connected_tile_pos = connected_tile_data.tile_pos
		var connected_tile_entry = connected_tile_data.entry_pos
		
		# Check if tile is starting tile
		var connected_tile = tile_board[connected_tile_pos.x][connected_tile_pos.y]
		if connected_tile == starting_tile:
			
			# Get list of tiles used to make cycle
			# var tiles_in_cycle = get_tiles
			
			# Check if next tile is in cycle list
			var next_tile_data = _get_connected_tile(connected_tile_pos, connected_tile_entry)
			if _is_tile_at(next_tile_data.tile_pos):
				var next_tile = _get_tile_at(next_tile_data.tile_pos)
				# if tiles_in_cycle.has(next_tile):
					
					# Increment multiplier of tiles in cycle list
					
					# If starting tile is not swoops or crossing break loop
					
					# pass
		
		# Add data to stack
		tile_stack.push_front(connected_tile_data)
		
		# Add tile to visited list
		# var curr_tile = tile_board[curr_tile.x][curr_tile.y]
		# tiles_searched[connected_tile] = curr_tile

# Returns the tile position and entry point the tile at the declared position 
# is connected to on the board given an entry direction. Returns null if no 
# such tile exists.
func _get_connected_tile(tile_pos, entry_point):
	
	# Get connected tile position
	var curr_tile = tile_board[tile_pos.x][tile_pos.y]
	var connected_tile_edge = curr_tile.get_connected_edge(entry_point)
	var connected_tile_vector = Tile.get_edge_vector(connected_tile_edge)
	var connected_tile_pos = tile_pos + connected_tile_vector
		
	# Check if tile is placed there
	if _is_tile_at(connected_tile_pos):
		
		# Return tile_pos and entry_point 
		var connected_tile_entry = Tile.get_opposite_edge(connected_tile_edge)
		return {"tile_pos": connected_tile_pos, "entry_point": connected_tile_entry}


# Determines if given tile position is valid and within board.
func _is_valid_pos(tile_pos):
	if tile_pos.x in range(0, BOARD_WIDTH - 1) and tile_pos.y in range(0, BOARD_HEIGHT - 1):
		return true
	else: 
		false


# Determines if given tile position is within board and if a tile exists at that
# position
func _is_tile_at(tile_pos):
	if _is_valid_pos(tile_pos):
		var tile_check = tile_board[tile_pos.x][tile_pos.y]
		if tile_check != null:
			return true
	return false


# Returns the tile at the given tile position. Returns null if no such tile 
# exists
func _get_tile_at(tile_pos):
	if _is_tile_at(tile_pos):
		return tile_board[tile_pos.x][tile_pos.y]
	return null


# On end of background music track play correct track 
# according to level
func _on_BackgroundMusic_finished():
	var file_path = "res://assets/audio/main_loop_level_" + str(level) + ".wav"
	var music_file = load(file_path)
	$BackgroundMusic.stream = music_file
	$BackgroundMusic.play()
