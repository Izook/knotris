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
	var board = get_parent().get_tile_board()
	var next_position = tile_position + MOVE_INPUTS[direction]
	if tile_position.y + MOVE_INPUTS[direction].y >= BOARD_HEIGHT:
		get_parent().add_tile(curr_tile, tile_position)
		reset_tile() 
	elif direction == 'move_down' && board[next_position.x][next_position.y] != null:
		if tile_position.y == 0:
			print("GAME OVER!!!")
			get_parent().queue_free()
		else:
			get_parent().add_tile(curr_tile, tile_position)
			reset_tile() 
	elif next_position.x > BOARD_WIDTH - 1 || next_position.x < 0:
		print("Illegal move attempted")
	elif board[next_position.x][next_position.y] != null:
		print("Illegal move attempted")
	else:
		tile_position = next_position
		curr_tile.position += MOVE_INPUTS[direction] * TILE_SIZE


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
	for direction in MOVE_INPUTS.keys():
		if event.is_action_pressed(direction):
			move_tile(direction)
			return
	for rotation in ROT_INPUTS.keys():
		if event.is_action_pressed(rotation):
			curr_tile.rotate(ROT_INPUTS[rotation])
			return


# Move down one tile on timeout
func _on_DropTimer_timeout():
	move_tile("move_down")