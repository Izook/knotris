extends Node2D

# Preload tile textures
var tileA_texture = preload("res://assets/tile_textures/tile_A.png")
var tileB_texture = preload("res://assets/tile_textures/tile_B.png")
var tileC_texture = preload("res://assets/tile_textures/tile_C.png")
var tileD_texture = preload("res://assets/tile_textures/tile_D.png")
var tileE_texture = preload("res://assets/tile_textures/tile_E.png")
var tile_textures = {
	"A" : tileA_texture,
	"B" : tileB_texture,
	"C" : tileC_texture,
	"D" : tileD_texture,
	"E" : tileE_texture,
}

# Global tile properties
const TILE_TYPES = Global.TILE_TYPES

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
	$TileSprite.set_texture(tile_textures[tile_type])


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
	$TileSprite.set_texture(tile_textures[tile_type])
	
	# Redefine connection points
	connection_points = [
		TILE_TYPES[tile_type].top,
		TILE_TYPES[tile_type].right,
		TILE_TYPES[tile_type].bottom,
		TILE_TYPES[tile_type].left
	]
