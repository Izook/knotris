extends Node2D

# Set script properties
export var tile_type = "B"
export var tile_rotation = 0

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

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.set_texture(tile_textures[tile_type])
	$Sprite.set_rotation((tile_rotation % 4) * (PI/2))
	pass 
