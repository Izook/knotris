extends Node2D

var board = preload("res://scenes/Board.tscn")
var tile_bag = preload("res://scenes/TileBag.tscn")
var hud = preload("res://scenes/HUD.tscn")

# Positioning constants
const TILE_SIZE = Global.TILE_SIZE
const BOARD_X_OFFSET = TILE_SIZE * 3

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Instantiate and place HUD
	var hud_instance = hud.instance()
	hud_instance.position = Vector2(0,0)
	add_child(hud_instance) 
	
	# Instantiate and place tilebag
	var tile_bag_instance = tile_bag.instance()
	tile_bag_instance.position = Vector2(0,0)
	add_child(tile_bag_instance)
	
	# Instantiate and place board
	var board_instance = board.instance()
	board_instance.position = Vector2(BOARD_X_OFFSET,0)
	add_child(board_instance)