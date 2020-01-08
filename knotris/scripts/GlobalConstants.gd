extends Node2D

# Board constants
const BOARD_WIDTH = 6
const BOARD_HEIGHT = 13
const BOARD_OFFSET_X = 16
const BOARD_OFFSET_Y = 16

# Tile constants
const TILE_SIZE = 32

# Tile types
const TILE_A = {
	"top" : false,
	"right" : false,
	"left" : false,
	"bottom" : false,
}
const TILE_B = {
	"top" : false,
	"right" : false,
	"left" : true,
	"bottom" : true,
}
const TILE_C = {
	"top" : true,
	"right" : false,
	"left" : false,
	"bottom" : true,
}
const TILE_D = {
	"top" : true,
	"right" : true,
	"left" : true,
	"bottom" : true,
}
const TILE_E = {
	"top" : true,
	"right" : true,
	"left" : true,
	"bottom" : true,
}
const TILE_TYPES = {
	"A" : TILE_A,
	"B" : TILE_B,
	"C" : TILE_C,
	"D" : TILE_D,
	"E" : TILE_E,
}
const TILE_TYPE_KEYS = ["A", "B", "C", "D", "E"]