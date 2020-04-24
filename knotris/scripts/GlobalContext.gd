extends Node2D

# Game constants
const GAME_WIDTH = 520
const GAME_HEIGHT = 560

# Tile constants
const TILE_SIZE = 40

# Board constants
const BOARD_WIDTH = 6
const BOARD_HEIGHT = 13
const BOARD_OFFSET_X = TILE_SIZE / 2
const BOARD_OFFSET_Y = TILE_SIZE / 2

# Tile Types
const TILE_A = {
	"top" : false,
	"right" : false,
	"bottom" : false,
	"left" : false,
}
const TILE_B = {
	"top" : false,
	"right" : true,
	"bottom" : true,
	"left" : false,
}
const TILE_C = {
	"top" : true,
	"right" : false,
	"bottom" : true,
	"left" : false,
}
const TILE_D = {
	"top" : true,
	"right" : true,
	"bottom" : true,
	"left" : true,
}
const TILE_E = {
	"top" : true,
	"right" : true,
	"bottom" : true,
	"left" : true,
}
const TILE_TYPES = {
	"A" : TILE_A,
	"B" : TILE_B,
	"C" : TILE_C,
	"D" : TILE_D,
	"E" : TILE_E,
}
const TILE_TYPE_KEYS = ["A", "B", "C", "D", "E"]

# Tile Textures
const TILE_A_TEXTURE = preload("res://assets/tile_textures/tile_A.png")
const TILE_B_TEXTURE = preload("res://assets/tile_textures/tile_B.png")
const TILE_C_TEXTURE = preload("res://assets/tile_textures/tile_C.png")
const TILE_D_TEXTURE = preload("res://assets/tile_textures/tile_D.png")
const TILE_E_TEXTURE = preload("res://assets/tile_textures/tile_E.png")
const TILE_TEXTURES = {
	"A" : TILE_A_TEXTURE,
	"B" : TILE_B_TEXTURE,
	"C" : TILE_C_TEXTURE,
	"D" : TILE_D_TEXTURE,
	"E" : TILE_E_TEXTURE,
}

# List of tile type + rotation combinations seperated by whether or not the left point is connected
const left_connected_combinations = []
const left_disconnected_combinations = []

# Whether or not audio is muted
var muted = false

func _ready():
	# Determine left connected tile + rotation combinations for board initialization
	for key in TILE_TYPE_KEYS:
		# Iterate through counterclockwise rotations
		for j in range(4):
			if TILE_TYPES[key].values()[(3 + j) % 4]:
				left_connected_combinations.append([key,j])
			else:
				left_disconnected_combinations.append([key,j])
	
	# Mute game if running on HTML iOS Export
	if OS.has_feature("iOSWeb"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		$AudioButton.set_normal_texture(load("res://assets/AudioOnIcon.png"))
		muted = true
