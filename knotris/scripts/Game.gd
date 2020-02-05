extends Node2D

var board = preload("res://scenes/Board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var board_instance = board.instance()
	add_child(board_instance)

