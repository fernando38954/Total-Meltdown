extends Node

const PATTERNS_DIR = "pattern/"

var all_patterns: Dictionary = {}
var locked_patterns: Array = []
var studiable_patterns: Array = []
var owned_patterns: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_patterns()
	GlobalSignal.game_start.connect(initialize)

func load_patterns():
	all_patterns.clear()
	var dir_path = GlobalResource.get_current_content_path() + PATTERNS_DIR
	var dir = DirAccess.open(dir_path)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", dir_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = dir_path + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					var key = data.get("key", "Unknown")
					var icon = load(data.get("icon", ""))
					if !icon:
						push_error("Error: Unable to load image:", data.get("icon", ""))
					all_patterns[key] = {
						"key": key,
						"quarter": data.get("quarter", -1),
						"title": data.get("title", "Untitled"),
						"icon": icon,
						"cost": data.get("cost", 0),
						"attribute": data.get("attribute", ""),
						"complexity_level": data.get("complexity_level", 0),
						"time_level": data.get("time_level", 0),
						"cost_level": data.get("cost_level", 0),
						"description": data.get("description", ""),
						"concept": data.get("concept", ""),
						"advantage": data.get("advantage", ""),
						"disadvantage": data.get("disadvantage", ""),
						"bullet_point": data.get("bullet_point", {}),
					}
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	creation_finished = true
	print_debug("Number of patterns loaded：", all_patterns.size())

func initialize():
	locked_patterns.clear()
	for i in range(GlobalResource.TOTAL_QUARTER):
		locked_patterns.append([])
	for pattern_key in all_patterns.keys():
		var pattern_data = get_pattern_by_key(pattern_key)
		locked_patterns[pattern_data.quarter].append(pattern_key)
	
	studiable_patterns.clear()
	owned_patterns.clear()
#endregion

#region Array Operation
func get_pattern_by_key(key: String) -> Dictionary:
	return all_patterns.get(key, {})

func prepare_random_patterns(count: int = 2) -> Array:
	var pattern_stock = locked_patterns[GlobalResource.current_quarter].duplicate()
	pattern_stock.shuffle()
	var selected = pattern_stock.slice(0, count)
	for pattern_entry in selected:
		locked_patterns[GlobalResource.current_quarter].erase(pattern_entry)
		studiable_patterns.append(pattern_entry)
	return selected

func study_pattern(studiable_patterns_list: Array, target_pattern_key: String, is_free: bool = false):
	for pattern_entry in studiable_patterns_list:
		if studiable_patterns.has(pattern_entry):
			studiable_patterns.erase(pattern_entry)
			if pattern_entry == target_pattern_key:
				GlobalResource.record_pattern_learning()
				owned_patterns.append(pattern_entry)
				if not is_free:
					pay_pattern(pattern_entry)
			else:
				locked_patterns[GlobalResource.current_quarter].append(pattern_entry)
		else:
			push_error("study_pattern: No pattern with key " + pattern_entry + " found in studiable_patterns_list")

func pay_pattern(target_pattern_key: String):
	var pattern_data = get_pattern_by_key(target_pattern_key)
	GlobalResource.change_money(-1 * pattern_data.cost)
#endregion
