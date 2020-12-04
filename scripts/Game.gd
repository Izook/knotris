extends Node2D

var Board = preload("res://scenes/Board.tscn")
var TileBag = preload("res://scenes/TileBag.tscn")
var HUD = preload("res://scenes/HUD.tscn")

# Positioning constants
var TILE_SIZE = Global.TILE_SIZE
var BOARD_X_OFFSET = TILE_SIZE * 3

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set background to gray
	VisualServer.set_default_clear_color(Color(0.25, 0.25, 0.25, 1))
		
	# Instantiate and place HUD
	var hud_instance = HUD.instance()
	hud_instance.rect_position = Vector2(0,0)
	add_child(hud_instance) 
	
	# Instantiate and place tilebag
	var tile_bag_instance = TileBag.instance()
	tile_bag_instance.position = Vector2(0,0)
	add_child(tile_bag_instance)
	
	# Instantiate and place board
	var board_instance = Board.instance()
	board_instance.position = Vector2(BOARD_X_OFFSET,0)
	add_child(board_instance)
	
