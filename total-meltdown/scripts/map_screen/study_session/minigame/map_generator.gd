extends Node
class_name PipeMapGenerator

const directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN, Vector2.UP]
var connected_coordinate_list: Dictionary[Vector2, bool] = {}

func generate_random_map(rows: int, cols: int, must_connect: Array, must_not_connect: Array):
	var grid = _empty_grid(rows, cols)
	
	# Connect with source and sink
	grid[0][0].connection[Vector2.LEFT] = true
	grid[rows-1][cols-1].connection[Vector2.RIGHT] = true
	
	# Create a path from start to end
	var start = Vector2(0, 0)
	var end = [Vector2(rows-1, cols-1)]
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
	
	# Randomize the configuration of connectionsfor i in range(rows):
	for i in range(rows):
		for j in range(cols):
			_ramdoly_active_cell_connection(grid[i][j])
	
	# Remove connections to prohibited cells
	for target in must_not_connect:
		_remove_cell_connection(grid, target)
	
	# Return grid
	for i in range(rows):
		for j in range(cols):
			var cell = grid[i][j]
			cell.deduce_type()
			cell.random_rotate()
	return grid

#region Auxiliary Function
func _empty_grid(rows: int, cols: int) -> Array:
	var empty_grid: Array[Array]
	empty_grid.resize(rows)
	for i in range(rows):
		var row: Array = []
		row.resize(cols)
		for j in range(cols):
			row[j] = PipeCell.new(Vector2(i, j))
		empty_grid[i] = row
	return empty_grid

func _random_path(start: Vector2, end_list: Array, forbidden: Array, rows: int, cols: int) -> Array:
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

func _is_valid_coordinate(coordinate: Vector2, rows: int, cols: int) -> bool:
	return coordinate.x >= 0 and coordinate.x < rows and coordinate.y >= 0 and coordinate.y < cols

func _neighbors(coordinate: Vector2, rows: int, cols: int) -> Array:
	var neighbors_list = []
	for direction in directions:
		var neighbors = coordinate + direction
		if _is_valid_coordinate(neighbors, rows, cols):
			neighbors_list.append(neighbors)
	return neighbors_list

func _get_grid_cell(grid: Array[Array], coordinate: Vector2) -> PipeCell:
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

func _ramdoly_active_cell_connection(cell: PipeCell):
	for direction in cell.connection:
		if randi_range(0, 1):
			cell.connection[direction] = true

func _remove_cell_connection(grid: Array[Array], coordinate: Vector2):
	var cell = _get_grid_cell(grid, coordinate)
	for direction in cell.connection:
		if cell.connection[direction]:
			var neighbor_cell = _get_grid_cell(grid, coordinate + direction)
			if neighbor_cell.connection[-1 * direction]:
				if cell.count_connection() >= neighbor_cell.count_connection():
					cell.connection[direction] = false
				else:
					neighbor_cell.connection[-1 * direction] = false

func print_grid(grid, rows, cols):
	for i in range(rows):
		var list = []
		for j in range(cols):
			var cell = grid[i][j]
			cell.deduce_type()
			cell.random_rotate()
			list.append(cell.pipe_type)
		print(" ".join(list))
	print()
#endregion


func _ready() -> void:
	var must_connect = [Vector2(1,2), Vector2(2,4)]
	var must_not_connect = [Vector2(2,2)]
	var grid = generate_random_map(4, 6, must_connect, must_not_connect)
	print_grid(grid, 4, 6)
