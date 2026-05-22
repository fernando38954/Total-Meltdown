extends Node
class_name PipeCell

var coordinate: Vector2
var connection: Dictionary[Vector2, bool]
var pipe_type: String
var rotation: int

func _init(_coordinate: Vector2):
	coordinate = _coordinate
	connection = {Vector2.UP: false, Vector2.DOWN: false, Vector2.LEFT: false, Vector2.RIGHT: false}

func count_connection() -> int:
	var counter = 0
	for existence in connection.values():
		if existence:
			counter += 1
	return counter

func deduce_type():
	var connection_number = count_connection()
	match connection_number:
		1: pipe_type = "O"
		2:
			if (connection[Vector2.UP] and connection[Vector2.DOWN]) or (connection[Vector2.LEFT] and connection[Vector2.RIGHT]):
				pipe_type = "I"
			else:
				pipe_type = "L"
		3: pipe_type = "T"
		4: pipe_type = "+"
		_: pipe_type = "O"

func random_rotate():
	var max_rotation = 1
	match pipe_type:
		"O", "L", "T": max_rotation = 4
		"I": max_rotation = 2
		"+": max_rotation = 1
	rotation = randi() % max_rotation
