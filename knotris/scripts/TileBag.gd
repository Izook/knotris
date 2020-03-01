extends Node2D

var tile = preload("res://scenes/Tile.tscn")

# Global parameters
const TILE_SIZE = Global.TILE_SIZE
const BOARD_WIDTH = Global.BOARD_WIDTH
const BOARD_X_OFFSET = TILE_SIZE * 4

# Tile Bag 
const bag_distribution = ["A", "B", "B", "C", "C", "D", "E"]

var upcoming_tiles = []
var upcoming_tile_keys = []

var upcoming_tile_positions = [
	Vector2(TILE_SIZE * (BOARD_WIDTH + 5), TILE_SIZE * 2),
	Vector2(TILE_SIZE * (BOARD_WIDTH + 5), TILE_SIZE * 4),
	Vector2(TILE_SIZE * (BOARD_WIDTH + 5), TILE_SIZE * 6)
]

var held_tile;
var held_tile_position = Vector2(TILE_SIZE*1, TILE_SIZE*2);

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Initially populate tile_keys 
	_populate_tile_bag()
		
	# Initialize and draw upcoming tiles
	for i in range(3):
		var new_tile = tile.instance()
		new_tile.init(upcoming_tile_keys[i], 0)
		new_tile.position = upcoming_tile_positions[i]
		add_child(new_tile)
		upcoming_tiles.append(new_tile)


# Populate upcoming tile keys with shuffled multiples of our tile_bag
func _populate_tile_bag():
	for i in range(3):
		var shuffled_bag = bag_distribution.duplicate()
		shuffled_bag.shuffle()
		upcoming_tile_keys += shuffled_bag


# Update upcoming tile types 
func _update_tiles():
	for i in range(3):
		upcoming_tiles[i].update_type(upcoming_tile_keys[i])


# Returns the a tile with the type of the next tile in the tile bag and updates the upcoming tiles
func get_next_tile():
	if upcoming_tile_keys.size() <= 3:
		_populate_tile_bag()
	
	var next_tile_type = upcoming_tile_keys.pop_front()
	var new_tile = tile.instance()
	new_tile.init(next_tile_type, 0)
	
	_update_tiles()
	
	return new_tile


# Returns the tile type the next tile in the tile bag and updates the upcoming tiles
func get_next_tile_type():
	if upcoming_tile_keys.size() <= 3:
		_populate_tile_bag()
	
	var next_tile_type = upcoming_tile_keys.pop_front()
	
	_update_tiles()
	
	return next_tile_type


# Takes players current tile type and switches it for the held tile type (or the next tile).
func get_held_tile_key(curr_tile_type):
	if held_tile == null:
		held_tile = tile.instance()
		held_tile.init(curr_tile_type, 0)
		held_tile.position = held_tile_position
		add_child(held_tile)
		
		return get_next_tile_type()
	else:
		var held_tile_type = held_tile.tile_type
		held_tile.update_type(curr_tile_type)
		
		return held_tile_type
