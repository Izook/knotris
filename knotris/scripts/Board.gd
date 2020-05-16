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
		
	# Add the Player to the board
	curr_player = Player.instance()
	add_child(curr_player)
	
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


# Adds new tile to the board at a declared position. Checks if any links, knots
# or complete rows were formed in the addition. If so it will increment the 
# multipliers, clear them, increase the score, and repeat as necc.
func add_tile(tile, tile_pos):
	if (tile_board[tile_pos.x][tile_pos.y] == null):
		# Place tile
		tile_board[tile_pos.x][tile_pos.y] = tile
		
		# Set disconnections
		_set_tile_disconnections(tile_pos)
		var right_tile_pos = tile_pos + Vector2(1,0)
		if _is_tile_at(right_tile_pos):
			_set_tile_disconnections(right_tile_pos)
		
		# Check for knots and cleared rows
		detect_knots([tile_pos])
		var new_points = check_rows()
		if new_points is GDScriptFunctionState:
			new_points = yield(new_points, "completed")
		
		# Retrieve the score
		var top_row = tile_pos.y
		var points_gained = 0
		var rows_cleared = 0
		while new_points > 0:
			rows_cleared = rows_cleared + 1
			points_gained = points_gained + new_points
			
			# Repeat as neccesary
			top_row = top_row + 1
			detect_knots(_get_row_at(top_row))
			new_points = check_rows()
			if new_points is GDScriptFunctionState:
				new_points = yield(new_points, "completed")
			
		# Update the score
		hud.increment_score(points_gained * rows_cleared)
			
	else:
		print("Illegal tile addition attempted.")
		tile.queue_free()


# Returns tile board
func get_tile_board():
	return tile_board


# Clear a row that is internally and externally suitably connected and moves 
# all other rows down appropriately. Returns values of row to be cleared.
func _clear_row(row_index):
	
	# Score of row cleared
	var row_value = 0
	
	# Clear all of the tiles
	var tiles_cleared = []
	for i in range(BOARD_WIDTH):
		row_value += tile_board[i][row_index].get_score()
		tile_board[i][row_index].clear_tile()
		tiles_cleared.push_front(tile_board[i][row_index])
		tile_board[i][row_index] = null
	
	# Await for single tile to be cleared (they all take the same time to clear)
	yield(tiles_cleared[0], "cleared")
	for tile in tiles_cleared:
		tile.queue_free()
	
	# Adjust all tiles above cleared row appropriately
	for j in range(row_index, 0, -1):
		
		for i in range(BOARD_WIDTH):
			# Move tiles down
			var above_tile = null
			if j > 0:
				above_tile = tile_board[i][j - 1]
			tile_board[i][j] = above_tile
			_draw_tile(i, j)
			_set_tile_disconnections(Vector2(i,j))
			
	# Send score to HUD	
	return row_value


# Checks rows for internal and external suitable connectedness. It clears the 
# row if such a row is found and returns the score gained from the row cleared.
func check_rows():
	for j in range(BOARD_HEIGHT - 1, -1, -1):
		var should_clear = true
		
		for i in range(BOARD_WIDTH):
			
			# Is row complete
			var curr_tile = _get_tile_at(Vector2(i, j))
			if curr_tile == null:
				should_clear = false
				break
				
			# Is row externally suitably connected
			var above_tile = _get_tile_at(Vector2(i, j - 1))
			if above_tile == null || curr_tile.connection_points[0] != above_tile.connection_points[2]:
				should_clear = false
				break
				
			# Is row internally suitably connected
			if i < BOARD_WIDTH - 2:
				var right_tile = _get_tile_at(Vector2(i + 1, j))
				if right_tile == null || curr_tile.connection_points[1] != right_tile.connection_points[3]:
					should_clear = false;
					break
		
		if should_clear:
			var row_score = _clear_row(j)
			return row_score
	return 0


# Performs a DFS on the graph of the strands on the board starting from the
# tiles givin in the array `starting_tile_positions`in order to detect any knots
# or links that may be on the board. If any links are found this function will 
# increment the multiplier of all tiles associated with that link appropriately.
func detect_knots(starting_tile_positions):
	
	# Stack of strands that will be iterated on to perfrom the DFS. Strands in 
	# the stack will the form defined by the functon `_get_strand_stack_dict`. 
	var strand_stack = []
	
	# Map of strands searched so that we may detect cycles that may appear in 
	# the graph of strands. Map will be in the form:
	# < strand_key, prev_strand_dict > which will be defined in the 
	# `_get_strand_key` function and `_get_strand_dict` function respectively. 
	var searched_strands = {}
	
	# Get all starting strands
	for tile_pos in starting_tile_positions:
		
		var curr_tile = _get_tile_at(tile_pos)
		
		# Edges already accounted for by strands found within the tiles
		var searched_edges = []
		
		# Add all strands contained within tile
		for i in range(4):
			
			if curr_tile.connection_points[i]:
				if not searched_edges.has(i):
					var origin_strand = _get_strand_dict(null, null)
					strand_stack.push_front(_get_strand_stack_dict(tile_pos, i, origin_strand))
					
					var connected_edge = curr_tile.get_connected_edge(i)
					searched_edges.push_front(connected_edge)
	
	# Count of how many strands have been searched
	var strand_count = 0
	
	while strand_stack.size() > 0:
		
		var curr_strand = strand_stack.pop_front()
		var curr_tile_pos = curr_strand.tile_pos
		var curr_tile = _get_tile_at(curr_tile_pos)
		
		# Get tiles attached to strand
		var entry_edge = curr_strand.entry_edge
		var exit_edge = curr_tile.get_connected_edge(entry_edge)
		var attached_edges = [entry_edge, exit_edge]
		
		# Get previous strand pos
		var prev_strand = curr_strand.prev_strand
		var prev_strand_pos = prev_strand.tile_pos
		
		for edge in attached_edges:
			
			# Ignore previous strand
			var attached_tile_pos = curr_tile_pos + Utility.get_edge_vector(edge)
			if attached_tile_pos == prev_strand_pos: 
				continue
			
			# Confirm attached strand is suitably connected
			if _are_tiles_connected(curr_tile_pos, attached_tile_pos, edge):
				
				var attached_entry_edge = Utility.get_opposite_edge(edge)
				var attached_strand_key = _get_strand_key(attached_tile_pos, attached_entry_edge)
				
				# If not yet searched add to stack
				if not searched_strands.has(attached_strand_key):
					strand_stack.push_front(_get_strand_stack_dict(attached_tile_pos, attached_entry_edge, curr_strand))
				else:					
					var strands_in_cycle = _get_strands_in_cycle(prev_strand, searched_strands)	
					strands_in_cycle.push_front(curr_tile_pos)
					
					# If complete cycle increment multipliers
					if strands_in_cycle.has(attached_tile_pos):
						_increment_multipliers(strands_in_cycle)
		
		# Add current strand to searched map
		var curr_strand_key = _get_strand_key(curr_tile_pos, entry_edge)
		searched_strands[curr_strand_key] = prev_strand
		
		# Increment count
		strand_count = strand_count + 1
	
	print("Strands Searched: " + str(strand_count))


# Returns a dictionary that can represent a strand to be searched and what 
# strand this was traversed from represented by `_get_strand_dict`.
func _get_strand_stack_dict(tile_pos, entry_edge, prev_strand):
	return {
		"tile_pos": tile_pos,
		"entry_edge": entry_edge,
		"prev_strand": prev_strand
	}


# Returns a dictionary that can represent a strand on the tile_board.
func _get_strand_dict(tile_pos, entry_edge):
	var smaller_edge = null
	
	if entry_edge != null:
		var tile = _get_tile_at(tile_pos)
		var exit_edge = tile.get_connected_edge(entry_edge)
		
		smaller_edge = min(int(entry_edge),int(exit_edge))
	
	return {
		"tile_pos": tile_pos,
		"entry_edge": smaller_edge,
	}


# Returns a string that can be used as a key to identify strands. 
func _get_strand_key(tile_pos, entry_edge):
	var smaller_edge = null
	
	if entry_edge != null:
		var tile = _get_tile_at(tile_pos)
		var exit_edge = tile.get_connected_edge(entry_edge)
		
		smaller_edge = min(int(entry_edge),int(exit_edge))
	
	return "[" + str(tile_pos) + ";" + str(smaller_edge) + "]"


# Given strand data and a dictionary of strands visited return the positions of 
# all the strands traversed from the orign strand ({null, null}).
func _get_strands_in_cycle(starting_strand, strands_searched):
	var strand_positions = []
	var next_strand = starting_strand
	
	while next_strand.tile_pos != null:
		strand_positions.push_back(next_strand.tile_pos)
		var next_strand_key = _get_strand_key(next_strand.tile_pos, next_strand.entry_edge)
		next_strand = strands_searched[next_strand_key].duplicate()
	
	return strand_positions


# Given a list of the position of strands increment the multipliers of each of 
# the tiles those strands are on based on the amount of crossings in the list.
func _increment_multipliers(tile_list):
	
	# Use a map to make sure a tiles are only counted once
	var tile_pos_map = {}
	
	# Count how high to increment the tiles
	var incrementer = 1
	for tile_pos in tile_list:
		if not tile_pos_map.has(tile_pos):
			tile_pos_map[tile_pos] = true
			var tile = _get_tile_at(tile_pos)
			if tile.tile_type == "E":
				incrementer = incrementer + 1
	
	# Increment all the tiles
	tile_pos_map = {}
	for tile_pos in tile_list:
		if not tile_pos_map.has(tile_pos):
			tile_pos_map[tile_pos] = true
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
		return null # _get_tile_data_dict(connected_tile_pos, connected_tile_entry)
	
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


# Given the position of two tiles, and a side relative to tile_a return true 
# if there is a disconnection between the two, false if not.
func _are_tiles_disconnected(tile_a_pos, tile_b_pos, edge):
	
	# Confirm the tiles are adjacent
	var pos_diff = tile_a_pos - tile_b_pos
	if pos_diff.length() > 1:
		print("Invalid disconnection check occured")
		return false
	
	# Get tiles
	var tile_a = _get_tile_at(tile_a_pos)
	var tile_b = _get_tile_at(tile_b_pos)
	
	# If either tile doesn't exist there cannot be a disconnection
	if tile_a == null or tile_b == null:
		return false
	
	# Confirm disconnection at edge
	var opposite_edge = Utility.get_opposite_edge(edge)
	return tile_a.connection_points[edge] != tile_b.connection_points[opposite_edge]


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


# Returns the tile at the given tile position. Returns null if no such tile 
# exists
func _get_tile_at(tile_pos):
	if _is_valid_pos(tile_pos):
		return tile_board[tile_pos.x][tile_pos.y]
	return null


# Returns the positions of all the tiles in a row given a row index.
func _get_row_at(row_index):
	var tile_positions = []
	if row_index in range(BOARD_HEIGHT):
		for i in range(BOARD_WIDTH):
			tile_positions.push_front(Vector2(i,row_index))
	return tile_positions


# Given a tile_position, determine the connection status of its left and bottom
# edges and set them appropriately.
func _set_tile_disconnections(tile_pos):
	
	# Confirm tile exists
	var tile = _get_tile_at(tile_pos)
	if tile != null:
		
		# Get bottom edge status
		var bottom_tile_pos = tile_pos + Vector2(0,1)
		var bottom_edge_status = _are_tiles_disconnected(tile_pos, bottom_tile_pos, 2)
		
		# Get left edge status
		var left_tile_pos = tile_pos + Vector2(-1,0)
		var left_edge_status = _are_tiles_disconnected(tile_pos, left_tile_pos, 3)
		
		# Set disconnections
		tile.set_disconnections(bottom_edge_status, left_edge_status)


# On end of background music track play correct track 
# according to level
func _on_BackgroundMusic_finished():
	var file_path = "res://assets/audio/main_loop_level_" + str(level) + ".wav"
	var music_file = load(file_path)
	$BackgroundMusic.stream = music_file
	$BackgroundMusic.play()
