extends Node2D

# Global tile properties
var TILE_TYPES = Global.TILE_TYPES
var TILE_TEXTURES = Global.TILE_TEXTURES

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


# Given an entry_edge to the tile return the edge that is connected to that 
# edge. Returns null if there is no such edge.
func get_connected_edge(entry_edge):
	
	if connection_points[entry_edge] == false:
		return null
	
	if tile_type == "A":
		return null
	
	if tile_type == "B" or tile_type == "D":
		if tile_rotation % 2 == 0:
			if entry_edge % 2 == 0:
				return get_righthanded_edge(entry_edge)
			elif entry_edge % 2 == 1:
				return get_lefthanded_edge(entry_edge)
		elif tile_rotation % 2 == 1:
			if entry_edge % 2 == 0:
				return get_lefthanded_edge(entry_edge)
			elif entry_edge % 2 == 1:
				return get_righthanded_edge(entry_edge)
	
	if tile_type == "C" or tile_type == "E":
		return get_opposite_edge(entry_edge)


# Given an edge return it as a Vector2 relative to the tile.
static func get_edge_vector(edge):
	if edge == 0:
		return Vector2(0,1)
	if edge == 1:
		return Vector2(1,0)
	if edge == 2: 
		return Vector2(0,-1)
	if edge == 3: 
		return Vector2(-1,0)


# Given an entry_edge to the tile return the edge that is connected to the right 
# corner of that edge. 
static func get_righthanded_edge(entry_edge):
	var righthanded_edge = entry_edge + 1 % 4
	return righthanded_edge


# Given an entry_edge to the tile return the edge that is connected to the left 
# corner of that edge. 
static func get_lefthanded_edge(entry_edge):
	var lefthanded_edge = entry_edge - 1 % 4
	if lefthanded_edge == -1:
		lefthanded_edge = lefthanded_edge + 1
	return lefthanded_edge


# Given an entry_edge to the tile return the edge that is on the opposite side 
# of that edge
static func get_opposite_edge(entry_edge):
	var opposite_edge = entry_edge + 2 % 4
	return opposite_edge
