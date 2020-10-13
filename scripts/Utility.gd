extends Node

# Utility represents multiple utility functions that can be called from anywhere
# within the game. 


# Given an edge of a tile return a Vector2 representing the edges position 
# relative to the tile.
static func get_edge_vector(edge):
	if edge == 0:
		return Vector2(0,-1)
	if edge == 1:
		return Vector2(1,0)
	if edge == 2: 
		return Vector2(0,1)
	if edge == 3: 
		return Vector2(-1,0)


# Given an entry_edge to a tile return the edge that is connected to the right 
# corner of that edge. 
static func get_righthanded_edge(entry_edge):
	var righthanded_edge = (entry_edge - 1) % 4
	if righthanded_edge == -1:
		righthanded_edge = 3
	return righthanded_edge


# Given an entry_edge to a tile return the edge that is connected to the left 
# corner of that edge. 
static func get_lefthanded_edge(entry_edge):
	var lefthanded_edge = (entry_edge + 1) % 4
	return lefthanded_edge


# Given an entry_edge to a tile return the edge that is on the opposite side 
# of that edge
static func get_opposite_edge(entry_edge):
	var opposite_edge = (entry_edge + 2) % 4
	return opposite_edge
