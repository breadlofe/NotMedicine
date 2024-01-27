extends Node2D

signal reached_patrol_point

var group_name : String
var positions_master : Array
var positions_to_visit : Array
var current_patrol_point : Marker2D
var direction : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _initialize():
	positions_master = get_tree().get_nodes_in_group(group_name)
	_get_positions()
	_get_next_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_patrol_point:
		if global_position.distance_to(current_patrol_point.position) < 10:
			reached_patrol_point.emit()
			_get_next_position()

func _get_positions():
	positions_to_visit = positions_master.duplicate()

func _get_next_position():
	if positions_to_visit.is_empty():
		_get_positions()
	current_patrol_point = positions_to_visit.pop_front()
		
	
