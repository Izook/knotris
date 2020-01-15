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
	"move_up": Vector2.UP,
}

# Current tile position
var tile_position = Vector2(0,0)

# Node representing the player
var curr_tile;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Get random tile and place it on the board
	curr_tile = get_parent().get_random_tile()
	var x_pos = (tile_position.x * TILE_SIZE) + OFFSET_X
	var y_pos = (tile_position.y * TILE_SIZE) + OFFSET_Y
	curr_tile.position = Vector2(x_pos, y_pos) 
	add_child(curr_tile)	


# Called every frame (delta = time passed since last frame)
func _process(delta):
	pass


# Move tile based towards a direction
func move(direction):
	tile_position += INPUTS[direction]
	curr_tile.position += INPUTS[direction] * TILE_SIZE


# Called when an InputEvent hasn't been consumed by _input() or any GUI.
func _unhandled_input(event):
    for direction in INPUTS.keys():
        if event.is_action_pressed(direction):
            move(direction)
