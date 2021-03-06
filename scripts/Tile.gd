extends Node2D

# Global tile properties
var TILE_TYPES = Global.TILE_TYPES
var TILE_TEXTURES = Global.TILE_TEXTURES
var LOCKED_TILE_TEXTURES = Global.LOCKED_TILE_TEXTURES

# Flag representing when the tile has been cleared
signal cleared

# Name of group holding disconnections
const diconnections_group = "Disconnections"

# Tile properties
var tile_type
var tile_rotation
var tile_multiplier
var locked

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
	tile_multiplier = 1
	
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


# Used to rotate the tile in -90 degree parts. E.g. turns = 3 would turn the 
# the tile 270 degress.
func rotate(turns):
	tile_rotation = int(fposmod(tile_rotation + turns, 4))
	
	# Rotate connection points (counter clockwise rotations)
	var prev_connection_points = connection_points.duplicate()
	for i in range(4):
		connection_points[i] = prev_connection_points[fposmod(i + turns, 4)] 
	
	# Rotate sprite appropriately 
	$TileSprite.set_rotation(fposmod(tile_rotation, 4) * (-PI/2))


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
				return Utility.get_righthanded_edge(entry_edge)
			elif entry_edge % 2 == 1:
				return Utility.get_lefthanded_edge(entry_edge)
		elif tile_rotation % 2 == 1:
			if entry_edge % 2 == 0:
				return Utility.get_lefthanded_edge(entry_edge)
			elif entry_edge % 2 == 1:
				return Utility.get_righthanded_edge(entry_edge)
	
	if tile_type == "C" or tile_type == "E":
		return Utility.get_opposite_edge(entry_edge)


# Given an value increment the multiplier value of this tile by that amount and 
# if the value is > 1 show the value.
func increment_multiplier(incrementer):
	print("YEET")
	tile_multiplier = tile_multiplier + incrementer
	
	if tile_multiplier > 1:
		$MultiplierLabel.text = str(tile_multiplier)
		$MultiplierLabel.visible = true


# Given the status of the bottom and left connections, hide or display the 
# disconnection icons as neccesary.
func set_disconnections(bottom_disconnected, left_disconnected):
	
	$DisconnectBottom.visible = false
	$DisconnectLeft.visible = false
	
	if bottom_disconnected:
		$DisconnectBottom.visible = true
	if left_disconnected: 
		$DisconnectLeft.visible = true


# Set the locked status of the tile changing the tile to its locked texture.
func set_locked(is_tile_locked):
	locked = is_tile_locked
	if locked:
		$TileSprite.set_texture(LOCKED_TILE_TEXTURES[tile_type])
	else:
		$TileSprite.set_texture(TILE_TEXTURES[tile_type])


# Return the score of clearing the tile
func get_score():
	return 100 * tile_multiplier


# Plays the tile clearing animation and deletes the tile node.
func clear_tile():
	$AnimationPlayer.play("Clear")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("cleared")
	return
