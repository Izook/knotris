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
# [0][0] represents the top left of the board
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


# Adds new tile to the board at a declared position. Checks if any links or 
# knots were formed in the addition.
func add_tile(tile, tile_pos):
	if (tile_board[tile_pos.x][tile_pos.y] == null):
		tile_board[tile_pos.x][tile_pos.y] = tile
		detect_knots(tile_pos)
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
				row_value += tile_board[i][j].get_score()
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
# This is **definitely not** optimized...
func detect_knots(tile_pos):
	var starting_tile = _get_tile_at(tile_pos)
	
	print("STARTING AT: " + str(tile_pos))
	
	# Stack of tiles to be searched with the entry point used to traverse 
	# to them.
	var tile_stack = []
	
	# Map of tiles searched in the DFS. The key of the map is defined in the
	# `_get_tile_data_key` function and the value of the map is a dictionary 
	# containing tile position and the strand information.
	var tiles_searched = {}
	
	# List of starting tile edges already searched by searching one side of the 
	# strand
	var starting_edges_sorted = []
	
	# Add all the tiles connected to the starting tile to the stack
	for i in range(4):
		
		var adjacent_tile_pos = tile_pos + Utility.get_edge_vector(i)
		
		if starting_edges_sorted.has(i):
			continue
		
		# Check if connected
		if _are_tiles_connected(tile_pos, adjacent_tile_pos, i):
			
			# Determine side of starting tile this edge connected to to prevent 
			# double searching strands
			var connected_edge = starting_tile.get_connected_edge(i)
			starting_edges_sorted.push_front(connected_edge)
			
			# Push strand data to stack and add it to visited list
			var adjacent_tile_entry_edge = Utility.get_opposite_edge(i)
			var adjacent_tile_dict = _get_tile_data_dict(adjacent_tile_pos, adjacent_tile_entry_edge)
			var adjacent_tile_key = _get_tile_data_key(adjacent_tile_dict)
			tile_stack.push_front(adjacent_tile_dict)
			tiles_searched[adjacent_tile_key] = _get_tile_data_dict(Vector2(-1,-1), -1)
	
	var search_count = 0
	
	# Go through all tiles in the stack until stack is empty
	while tile_stack.size() > 0:
		
		search_count = search_count + 1
		
		# Get next strand data from stack
		var curr_tile_data = tile_stack.pop_front()
		var curr_tile_pos = curr_tile_data.tile_pos
		var curr_tile_entry_edge = curr_tile_data.entry_edge
		
		print("CURRENT: " + _get_tile_data_key(curr_tile_data))
		
		# Get tile connected to strand
		var next_tile_data = _get_connected_tile(curr_tile_pos, curr_tile_entry_edge)
		
		# Confirm next tile exists
		if next_tile_data == null: 
			continue 
			
		var next_tile_pos = next_tile_data.tile_pos
		var next_tile_entry = next_tile_data.entry_edge
		
		if _get_tile_at(next_tile_pos) == starting_tile:
			print("NEXT TILE IS STARTING TILE")
			
		# Check if current tile is starting tile
		var curr_tile = _get_tile_at(curr_tile_pos)
		if curr_tile == starting_tile:
			
			print("Current tile is starting tile.")
			
			# Get list of tiles used to make cycle
			var tiles_in_cycle = _get_tiles_in_cycle(curr_tile_data, tiles_searched)
			
			# Check if upcoming tile is in cycle list (check if strand is closed)
			if tiles_in_cycle.has(next_tile_pos):
				
				# Increment the multipliers of the tiles in the cycle
				_increment_multipliers(tiles_in_cycle)
				
				# If not a "swoops" nor "crossing" tile break out of DFS
				if (starting_tile.tile_type != "D" and starting_tile.tile_type != "E"):
					break	
		
		# Confirm tiles are suitable connected
		if not _are_tiles_connected(curr_tile_pos, next_tile_pos, Utility.get_opposite_edge(next_tile_entry)):
			continue
		
		# If next tile has not already been searched push it to stack and add it
		# to the searched list
		var next_tile_data_key = _get_tile_data_key(next_tile_data)
		print("NEXT: " + next_tile_data_key)
		if not tiles_searched.has(next_tile_data_key):
			
			# Add data to stack
			tile_stack.push_front(next_tile_data)
			
			# Add data to visited list
			tiles_searched[next_tile_data_key] = curr_tile_data
	
	print("Tiles Searched: " + str(search_count))


# Given tile data and a dictionary of tiles visited return the positions of all
# the tiles traversed from the starting tile ({-1, -1}).
func _get_tiles_in_cycle(tile_data, tiles_searched):
	var cycled_tiles = []
	var next_data = tile_data
	
	while next_data.entry_edge != -1:
		cycled_tiles.push_back(next_data.tile_pos)
		var next_data_key = _get_tile_data_key(next_data)
		next_data = tiles_searched[next_data_key].duplicate()
	
	return cycled_tiles


# Given a list of the position of tiles increment the multipliers of each of the
# tiles based on the amount of crossing tiles in the list.
func _increment_multipliers(tile_list):
	
	print("Incrementing multipliers")
	
	var incrementer = 1
	
	for tile_pos in tile_list:
		var tile = _get_tile_at(tile_pos)
		if tile.tile_type == "E":
			incrementer = incrementer + 1
	
	for tile_pos in tile_list:
		var tile = _get_tile_at(tile_pos)
		tile.increment_multiplier(incrementer)


# Returns the tile position and entry point of to be entered from the tile at
# the declared position and entry direction. Returns null if no such tile exists.
func _get_connected_tile(tile_pos, entry_edge):
	
	# Get connected tile position
	var curr_tile = _get_tile_at(tile_pos)
	var connected_tile_edge = curr_tile.get_connected_edge(entry_edge)
	
	if connected_tile_edge == null:
		return null
	
	var connected_tile_vector = Utility.get_edge_vector(connected_tile_edge)
	var connected_tile_pos = tile_pos + connected_tile_vector
		
	# Check if tile is placed there
	if _is_tile_at(connected_tile_pos):
		
		# Return tile_pos and entry_point 
		var connected_tile_entry = Utility.get_opposite_edge(connected_tile_edge)
		return _get_tile_data_dict(connected_tile_pos, connected_tile_entry)
	
	return null


# Given the position of two tiles, and a side relative to tile_a return true 
# if they are suitable connected, false if not.
func _are_tiles_connected(tile_a_pos, tile_b_pos, edge):
	
	# Confirm the tiles are adjacent
	var pos_diff = tile_a_pos - tile_b_pos
	if pos_diff.length() > 1:
		return false
	
	# Confirm tiles exist
	var tile_a = _get_tile_at(tile_a_pos)
	var tile_b = _get_tile_at(tile_b_pos)
	
	if tile_a == null or tile_b == null:
		return false
	
	# Confirm connection at edge
	var opposite_edge = Utility.get_opposite_edge(edge)
	return tile_a.connection_points[edge] and tile_b.connection_points[opposite_edge]


# Determines if given tile position is valid and within board.
func _is_valid_pos(tile_pos):
	if tile_pos.x in range(0, BOARD_WIDTH) and tile_pos.y in range(0, BOARD_HEIGHT):
		return true
	else: 
		false


# Determines if given tile position is within board and if a tile exists at that
# position
func _is_tile_at(tile_pos):
	return _get_tile_at(tile_pos) != null


# Returns a key contstructed from the tile_data so that it can be used for the 
# visited tiles list in the `detect_knots` DFS. It returns a unique identifier
# for strands in a tile. 
func _get_tile_data_key(tile_data):
	var tile_pos = tile_data.tile_pos
	var entry_edge = tile_data.entry_edge
	var exit_edge = tile_data.exit_edge
	
	var smaller_edge = min(int(entry_edge),int(exit_edge))
	
	return "[" + str(tile_pos) + ";" + str(smaller_edge) + "]"


# Given the tile position, tile entry edge, and tile exit edge this returns a
# dictionary containing all that data so that it can be used in the visited
# tiles list in the `detect_knots` DFS. 
func _get_tile_data_dict(tile_pos, entry_edge):
	var tile = _get_tile_at(tile_pos)
	var exit_edge
	if (tile != null):
		exit_edge = tile.get_connected_edge(entry_edge)
	else:
		exit_edge = -1
	return {"tile_pos": tile_pos, "entry_edge": entry_edge, "exit_edge": exit_edge}


# Returns the tile at the given tile position. Returns null if no such tile 
# exists
func _get_tile_at(tile_pos):
	if _is_valid_pos(tile_pos):
		return tile_board[tile_pos.x][tile_pos.y]
	return null


# On end of background music track play correct track 
# according to level
func _on_BackgroundMusic_finished():
	var file_path = "res://assets/audio/main_loop_level_" + str(level) + ".wav"
	var music_file = load(file_path)
	$BackgroundMusic.stream = music_file
	$BackgroundMusic.play()
