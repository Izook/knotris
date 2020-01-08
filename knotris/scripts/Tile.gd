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

# Tile properties
var tile_type
var tile_rotation

# Tile connection points
var connection_points = {
	"top" : false,
	"right" : false,
	"left" : false,
	"bottom" : false,
}

# Called after instancing scene, but before added to tree.
func init(type, rotation):
	# Define tile properties
	tile_type = type
	tile_rotation = rotation % 4
	
	# Define connection points
	var unrotated_points = [
		Global.TILE_TYPES[tile_type].top,
		Global.TILE_TYPES[tile_type].right,
		Global.TILE_TYPES[tile_type].left,
		Global.TILE_TYPES[tile_type].bottom,
	]
	
	# Rotate connection points
	connection_points.top = unrotated_points[rotation] 
	connection_points.right = unrotated_points[(1 + rotation) % 4]
	connection_points.left = unrotated_points[(2 + rotation) % 4]
	connection_points.bottom = unrotated_points[(3 + rotation) % 4]


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.set_texture(tile_textures[tile_type])
	$Sprite.set_rotation((tile_rotation % 4) * (PI/2))
	pass 
