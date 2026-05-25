extends Control
class_name PipeGame

#region Constants
const DIR_UP = Vector2i(-1, 0)
const DIR_DOWN = Vector2i(1, 0)
const DIR_LEFT = Vector2i(0, -1)
const DIR_RIGHT = Vector2i(0, 1)
#endregion

@export_category("Game Data")
@export var rows: int = 4
@export var cols: int = 6
var must_connect: Array
var must_not_connect: Array
var generator: PipeMapGenerator
var cells_grid: Array[Array]
var game_finished: bool

@export_category("Bullet Points")
var correct_bullets: Array
var wrong_bullets: Array

@export_category("Visual Component")
@onready var grid_container = $GridContainer
@onready var sink = $Sink
@export var sink_active: Texture2D
@export var sink_inactive: Texture2D
var open_scale = Vector2(0.8, 0.8)
var tween: Tween

func _ready():
	close_game(0)
	var cells = grid_container.get_children()
	generator = PipeMapGenerator.new()
	cells_grid.resize(rows)
	for i in range(rows):
		var row: Array = []
		row.resize(cols)
		for j in range(cols):
			row[j] = cells[i * cols + j]
			cells[i * cols + j].assign_game(self)
		cells_grid[i] = row

#region Game Panel Action
func rescale_game(target_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, duration)

func close_game(duration: float = 0.5):
	rescale_game(Vector2.ZERO, duration)

func open_game(duration: float = 0.5):
	rescale_game(open_scale, duration)
#endregion

#region Game flow
func generate_random_constraints():
	var start_pos = Vector2i(0, 0)
	var end_pos = Vector2i(rows - 1, cols - 1)

	var all_positions: Array[Vector2i] = []
	for i in range(rows):
		for j in range(cols):
			var pos = Vector2i(i, j)
			if pos != start_pos and pos != end_pos:
				all_positions.append(pos)
	all_positions.shuffle()
	
	var connect_count = randi_range(2, 4)
	var not_connect_count = randi_range(max(1, 4 - connect_count), min(3, 7 - connect_count))
	must_connect.clear()
	must_not_connect.clear()
	
	for counter in range(0, connect_count + not_connect_count):
		if counter < connect_count:
			must_connect.append(all_positions[counter])
		else:
			must_not_connect.append(all_positions[counter])

func get_random_bullet_points(target_pattern_key: String):
	var target_pattern_data = PatternManager.get_pattern_by_key(target_pattern_key)
	var target_bullet_points = target_pattern_data.bullet_point.values()
	target_bullet_points.shuffle()
	correct_bullets = target_bullet_points.slice(0, must_connect.size())
	
	var other_bullets = []
	for key in PatternManager.all_patterns:
		if key == target_pattern_key:
			continue
		var other_pattern_data = PatternManager.all_patterns[key]
		other_bullets.append_array(other_pattern_data.bullet_point.values())
	other_bullets.shuffle()
	wrong_bullets = other_bullets.slice(0, must_not_connect.size())

func generate_and_build_grid(target_pattern_key: String):
	while true: # Repeat until get a valid map
		generate_random_constraints()
		get_random_bullet_points(target_pattern_key)
		game_finished = false
		var data_grid = generator.generate_random_map(rows, cols, must_connect, must_not_connect)
		if data_grid.is_empty():
			push_error("Error: Map generation failed")
			continue
		
		for i in range(rows):
			for j in range(cols):
				cells_grid[i][j].copy(data_grid[i][j])
		
		for idx in range(must_connect.size()):
			var target_cell = cells_grid[must_connect[idx].x][must_connect[idx].y]
			target_cell.set_description(correct_bullets[idx])
			
		for idx in range(must_not_connect.size()):
			var target_cell = cells_grid[must_not_connect[idx].x][must_not_connect[idx].y]
			target_cell.set_description(wrong_bullets[idx])
		
		update_active_status()
		
		if not game_finished:
			break
		
		push_error("Error: Map finished on start")

func _is_valid_coordinate(coordinate: Vector2i) -> bool:
	return coordinate.x >= 0 and coordinate.x < rows and coordinate.y >= 0 and coordinate.y < cols

func update_active_status():
	var visited = {}
	var queue = []
	
	if cells_grid[0][0].connection[DIR_LEFT]:
		queue.append(Vector2i(0,0))
		visited[Vector2i(0,0)] = true
	while queue.size() > 0:
		var coordinate = queue.pop_front()
		var cell = cells_grid[coordinate.x][coordinate.y]
		
		for direction in [DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT]:
			if cell.connection[direction]:
				var neighbors = coordinate + direction
				if _is_valid_coordinate(neighbors):
					var neighbor_cell = cells_grid[neighbors.x][neighbors.y]
					if neighbor_cell.connection[-1 * direction] and not visited.has(neighbors):
						visited[neighbors] = true
						queue.append(neighbors)
	
	for i in range(rows):
		for j in range(cols):
			cells_grid[i][j].set_active(visited.has(Vector2i(i,j)))
	
	game_win_check()

func game_win_check():
	var sink_connected = false
	if cells_grid[rows-1][cols-1].connection[DIR_RIGHT] and cells_grid[rows-1][cols-1].is_actived:
		sink_connected = true
	sink.texture = sink_active if sink_connected else sink_inactive
	
	var all_required_connected = true
	for coordinate in must_connect:
		if not cells_grid[coordinate.x][coordinate.y].is_actived:
			all_required_connected = false
			break
	
	var all_prohibited_unconnected = true
	for coordinate in must_not_connect:
		if cells_grid[coordinate.x][coordinate.y].is_actived:
			all_prohibited_unconnected = false
			break
	
	if sink_connected and all_required_connected and all_prohibited_unconnected:
		game_finished = true
		close_game()
		GlobalSignal.emit_signal("start_tutorial", "AfterStudy")
		GlobalSignal.emit_signal("minigame_finished")
#endregion
