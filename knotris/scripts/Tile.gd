extends Node2D

# Global tile properties
const TILE_TYPES = Global.TILE_TYPES
const TILE_TEXTURES = Global.TILE_TEXTURES

# Tile properties
var tile_type
var tile_rotation
var tile_score

# Tile connection points
var connection_points = [
	false, # top
	false, # right
	false, # bottom
	false  # left
]

# Called after instancing scene, but before added to tree.
func init(type, rotation):
	# Define tile properties
	tile_type = type
	tile_rotation = 0
	tile_score = 100
	
	# Define connection points
	connection_points = [
		TILE_TYPES[tile_type].top,
		TILE_TYPES[tile_type].right,
		TILE_TYPES[tile_type].bottom,
		TILE_TYPES[tile_type].left
	]
	
	# Rotate tile
	rotate(rotation)


# Called when the node enters the scene tree for the first time.
func _ready():
	$TileSprite.set_texture(TILE_TEXTURES[tile_type])


# Used to rotate the tile in -90 degree parts
# `turns` must be within [0,3]
func rotate(turns):
	tile_rotation = (tile_rotation + turns) % 4
	
	# Rotate connection points (counter clockwise rotations)
	var prev_connection_points = connection_points.duplicate()
	for i in range(4):
		connection_points[i] = prev_connection_points[(i + turns) % 4] 
	
	# Rotate sprite appropriately 
	$TileSprite.set_rotation((tile_rotation % 4) * (-PI/2))


# Used to update the tile type 
func update_type(type):
	
	# Update properties
	tile_type = type
	$TileSprite.set_texture(TILE_TEXTURES[tile_type])
	
	# Redefine connection points
	connection_points = [
		TILE_TYPES[tile_type].top,
		TILE_TYPES[tile_type].right,
		TILE_TYPES[tile_type].bottom,
		TILE_TYPES[tile_type].left
	]
