extends Node2D

# Constant board parameters
const OFFSET_X = Global.BOARD_OFFSET_X
const OFFSET_Y = Global.BOARD_OFFSET_Y
const BOARD_HEIGHT = Global.BOARD_HEIGHT
const BOARD_WIDTH = Global.BOARD_WIDTH

# Constant tile parameters
const TILE_SIZE = Global.TILE_SIZE

# Define inputs from input map
const MOVE_INPUTS = {
	"move_right": Vector2.RIGHT,
	"move_down": Vector2.DOWN,
	"move_left": Vector2.LEFT,
}
const ROT_INPUTS = {
	"rotate_right": 3,
	"rotate_left": 1,
}

# Refernce to ancestor HUD node
var hud

# Current tile position
var tile_position = Vector2(0,0)

# Node representing the player
var curr_tile;

# Time between drops during descent (seconds)
var drop_time = 1;

# Starting position of swipes
var swipe_start;

# Ending position of swipes
var swipe_end;

# Minimum time in seconds between any touch input
# NOTE: This only exists for iOS Web Support
var input_lag = 0.1

# The minimum length a swipe needs to meet
const MINIMUM_DRAG = 80;

# Reference to the input timer incharge of touch input lag
var input_timer

# Reference to ancestor TileBag node
var tile_bag

# Reference to parent Board node
var tile_board

# Has the player held this tile already?
var has_held_tile = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Populate hud node reference
	hud = get_parent().get_parent().get_node("HUD")
	
	# Populate TileBag and Board refernce
	tile_bag = get_parent().get_parent().get_node("TileBag")
	tile_board = get_parent()
	
	# Set current tile
	reset_tile()
	
	# Start DropTimer and connect timeout signal
	$DropTimer.wait_time = drop_time
	$DropTimer.start()
	$DropTimer.connect("timeout", self, "_on_DropTimer_timeout")


# Move tile based towards a direction
func move_tile(direction):
	var board = tile_board.get_tile_board()
	var next_position = tile_position + MOVE_INPUTS[direction]
	if tile_position.y + MOVE_INPUTS[direction].y >= BOARD_HEIGHT:
		get_parent().add_tile(curr_tile, tile_position)
		reset_tile() 
	elif direction == 'move_down' && board[next_position.x][next_position.y] != null:
		if tile_position.y == 0:
			hud.game_over()
		else:
			place_tile(tile_position)
	elif next_position.x > BOARD_WIDTH - 1 || next_position.x < 0:
		print("Illegal move attempted")
	elif board[next_position.x][next_position.y] != null:
		print("Illegal move attempted")
	else:
		tile_position = next_position
		curr_tile.position += MOVE_INPUTS[direction] * TILE_SIZE


# Rotates the tile
func rotate_tile(rotation):
	$RotateSound.play()
	curr_tile.rotate(ROT_INPUTS[rotation])


# Places the tile on the board and resets the players tile
func place_tile(tile_position):
	$DropSound.play()
	tile_board.add_tile(curr_tile, tile_position)
	reset_tile() 


# Moves the tile as low as it can go and palce it
func drop_tile(): 
	var board = tile_board.get_tile_board()
	var next_position = tile_position + MOVE_INPUTS["move_down"]
	
	# As low as possible
	while board[next_position.x][next_position.y] == null:
		move_tile("move_down")
		board = tile_board.get_tile_board()
		next_position = tile_position + MOVE_INPUTS["move_down"]
	
	# Place the tile
	move_tile("move_down")


# Check board for SC rows & set current tile to a random tile and place it on the board
func reset_tile():
	# Check board for complete rows
	var cleared_row_count = tile_board.check_rows()
	if cleared_row_count > 1:
		print("CLEARED: " + cleared_row_count as String + " rows!!!")
	
	# Reset tile holding functionality
	has_held_tile = false
	
	curr_tile = tile_bag.get_next_tile()
	reposition_tile()
	add_child(curr_tile)


# Updates the held tile with the currently active tile.
func hold_tile():
	if !has_held_tile: 
		has_held_tile = true
		curr_tile.update_type(tile_bag.get_held_tile_key(curr_tile.tile_type))
		reposition_tile()
		return


# Resets the position of the tile to the top of the screen
func reposition_tile():
	tile_position.y = 0
	var x_pos = (tile_position.x * TILE_SIZE) + OFFSET_X
	var y_pos = (tile_position.y * TILE_SIZE) + OFFSET_Y
	curr_tile.position = Vector2(x_pos, y_pos) 


# Called every frame, delta represents time passed since last processing 
func _process(delta):
	pass


# Called when an InputEvent hasn't been consumed by _input() or any GUI.
func _unhandled_input(event):
	
	if event.is_action_pressed("pause_game"):
		hud.pause()
		return
		
	if event.is_action_pressed("hold_tile"):
		hold_tile()
		return
			
	if event.is_action_pressed("drop_tile"):
		drop_tile()
		return
	
	for direction in MOVE_INPUTS.keys():
		if event.is_action_pressed(direction):
			move_tile(direction)
			return
			
	if event.is_action_pressed("click"):
		swipe_start = event.position
		return
	elif event.is_action_released("click"):
		_calculate_swipe(event.position)
		return
	
	for rotation in ROT_INPUTS.keys():
		if event.is_action_pressed(rotation):
			rotate_tile(rotation)
			return


# Called whenever a swipe ends, determines what action to trigger.
func _calculate_swipe(event_position):
	
	if swipe_start == null or swipe_end != null: 
		return
		
	if $InputTimer.get_time_left() != 0 and OS.has_feature("iOSWeb"):
		return
	
	swipe_end = event_position
	$InputTimer.start(input_lag)

	var swipe = event_position - swipe_start
	
	if swipe.y < 0 - MINIMUM_DRAG:
		hold_tile()
	if swipe.y > MINIMUM_DRAG * 1.5:
		drop_tile()
	elif swipe.y > MINIMUM_DRAG:
		move_tile("move_down")
	elif abs(swipe.x) > MINIMUM_DRAG:
		if swipe.x > 0:
			move_tile("move_right")
		else:
			move_tile("move_left")
	else:
		rotate_tile("rotate_right")
	
	swipe_start = null
	swipe_end = null


# Move down one tile on timeout
func _on_DropTimer_timeout():
	move_tile("move_down")


# Send message to secret debugger
func _secret_debug(message):
	var secret_debugger = get_parent().get_node("SecretDebugger")
	var current_message = secret_debugger.get_text()
	secret_debugger.set_text(current_message + "\n" + message)
