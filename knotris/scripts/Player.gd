extends Node2D

# Constant board parameters
const OFFSET_X = Global.BOARD_OFFSET_X
const OFFSET_Y = Global.BOARD_OFFSET_Y

# Constant tile parameters
const TILE_SIZE = Global.TILE_SIZE

# Define inputs from input map
const INPUTS = {
	"move_right": Vector2.RIGHT,
	"move_down": Vector2.DOWN,
	"move_left": Vector2.LEFT,
}

# Current tile position
var tile_position = Vector2(0,0)

# Node representing the player
var curr_tile;

# Time between drops during descent (seconds)
var drop_time = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set current tile
	reset_tile()
	
	# Start DropTimer and connect timeout signal
	$DropTimer.wait_time = drop_time
	$DropTimer.start()
	$DropTimer.connect("timeout", self, "_on_DropTimer_timeout")


# Move tile based towards a direction
func move_tile(direction):
	if direction != "move_down":
		tile_position += INPUTS[direction]
		curr_tile.position += INPUTS[direction] * TILE_SIZE
	else:
		var board = get_parent().get_tile_board()
		if board[tile_position.x][tile_position.y + 1] != null:
			get_parent().add_tile(curr_tile, tile_position)
			reset_tile()
		else:
			tile_position += INPUTS[direction]
			curr_tile.position += INPUTS[direction] * TILE_SIZE


# Get set current tile to a random tile and place it on the board
func reset_tile():
	tile_position.y = 0
	curr_tile = get_parent().get_random_tile()
	var x_pos = (tile_position.x * TILE_SIZE) + OFFSET_X
	var y_pos = (tile_position.y * TILE_SIZE) + OFFSET_Y
	curr_tile.position = Vector2(x_pos, y_pos) 
	add_child(curr_tile)


# Called every frame, delta represents time passed since last processing 
func _process(delta):
	pass


# Called when an InputEvent hasn't been consumed by _input() or any GUI.
func _unhandled_input(event):
	for direction in INPUTS.keys():
		if event.is_action_pressed(direction):
	        move_tile(direction)


# Move down one tile on timeout
func _on_DropTimer_timeout():
	move_tile("move_down")