extends Node
class_name PipeMapGenerator

#region Constants
const DIR_UP = Vector2i(-1, 0)
const DIR_DOWN = Vector2i(1, 0)
const DIR_LEFT = Vector2i(0, -1)
const DIR_RIGHT = Vector2i(0, 1)
const DIRECTIONS = [DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT]
#endregion

var connected_coordinate_list: Dictionary[Vector2i, bool] = {}

func generate_random_map(rows: int, cols: int, must_connect: Array, must_not_connect: Array):
	var grid = _empty_grid(rows, cols)
	connected_coordinate_list.clear()
	
	# Connect with source and sink
	grid[0][0].connection[DIR_LEFT] = true
	grid[rows-1][cols-1].connection[DIR_RIGHT] = true
	
	# Create a path from start to end
	var start = Vector2i(0, 0)
	var end = [Vector2i(rows-1, cols-1)]
	var main_path = _random_path(start, end, must_not_connect, rows, cols)
	if main_path.is_empty():
		push_error("Error: main road not found")
		return []
	_add_path_connection(grid, main_path)
	
	# Connect with required cells
	for target in must_connect:
		if connected_coordinate_list.has(target):
			continue
		var path = _random_path(target, connected_coordinate_list.keys(), must_not_connect, rows, cols)
		if path.is_empty():
			push_error("Error: Unable to connect to ", target)
			return []
		_add_path_connection(grid, path)
	
	# Randomize the configuration of connections
	for i in range(rows):
		for j in range(cols):
			var is_prohibited = Vector2(i, j) in must_not_connect
			_ramdoly_active_cell_connection(grid[i][j], is_prohibited)
	
	# Remove connections to prohibited cells
	for target in must_not_connect:
		_remove_cell_connection(grid, target, rows, cols)
	
	# Return grid
	for i in range(rows):
		for j in range(cols):
			var cell = grid[i][j]
			cell.deduce_type()
	return grid

#region Auxiliary Function
func _empty_grid(rows: int, cols: int) -> Array:
	var empty_grid: Array[Array]
	empty_grid.resize(rows)
	for i in range(rows):
		var row: Array = []
		row.resize(cols)
		for j in range(cols):
			row[j] = PipeCell.new()
		empty_grid[i] = row
	return empty_grid

func _random_path(start: Vector2i, end_list: Array, forbidden: Array, rows: int, cols: int) -> Array:
	var queue = [[start]]
	var visited = {start: true}
	while queue:
		queue.shuffle()
		var path = queue.pop_front()
		var current_coordinate = path[-1]
		if current_coordinate in end_list:
			return path
		for neighbors in _neighbors(current_coordinate, rows, cols):
			if not visited.has(neighbors) and not forbidden.has(neighbors):
				visited[neighbors] = true
				var new_path = path.duplicate()
				new_path.append(neighbors)
				queue.append(new_path)
	return []

func _is_valid_coordinate(coordinate: Vector2i, rows: int, cols: int) -> bool:
	return coordinate.x >= 0 and coordinate.x < rows and coordinate.y >= 0 and coordinate.y < cols

func _neighbors(coordinate: Vector2i, rows: int, cols: int) -> Array:
	var neighbors_list = []
	for direction in DIRECTIONS:
		var neighbors = coordinate + direction
		if _is_valid_coordinate(neighbors, rows, cols):
			neighbors_list.append(neighbors)
	return neighbors_list

func _get_grid_cell(grid: Array[Array], coordinate: Vector2i) -> PipeCell:
	return grid[coordinate.x][coordinate.y]

func _add_path_connection(grid: Array[Array], path: Array):
	connected_coordinate_list[path[0]] = true
	for i in range(path.size()-1):
		var current_coordinate = path[i]
		var next_coordinate = path[i+1]
		connected_coordinate_list[next_coordinate] = true
		var direction = next_coordinate - current_coordinate
		_get_grid_cell(grid, current_coordinate).connection[direction] = true
		_get_grid_cell(grid, next_coordinate).connection[-1 * direction] = true

func _ramdoly_active_cell_connection(cell: PipeCell, is_prohibited: bool):
	for direction in cell.connection:
		var activating_probability = 0.4
		var prohibited_cell_bonus = 0.3 if is_prohibited else 0.0
		if randf() < activating_probability + prohibited_cell_bonus:
			cell.connection[direction] = true

func _remove_cell_connection(grid: Array[Array], coordinate: Vector2i, rows: int, cols: int):
	var cell = _get_grid_cell(grid, coordinate)
	for direction in cell.connection:
		if cell.connection[direction] and _is_valid_coordinate(coordinate + direction, rows, cols):
			var neighbor_cell = _get_grid_cell(grid, coordinate + direction)
			if neighbor_cell.connection[-1 * direction]:
				if cell.count_connection() == 1 && neighbor_cell.count_connection() == 1:
					continue
				if cell.count_connection() >= neighbor_cell.count_connection():
					cell.connection[direction] = false
				else:
					neighbor_cell.connection[-1 * direction] = false
#endregion

func print_grid(grid, rows, cols):
	for i in range(rows):
		var list = []
		for j in range(cols):
			var cell = grid[i][j]
			cell.deduce_type()
			list.append(cell.pipe_type)
		print(" ".join(list))
	print()
