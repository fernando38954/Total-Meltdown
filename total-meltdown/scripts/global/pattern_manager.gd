extends Node

const PATTERNS_DIR = "res://contents/pattern/"

var all_patterns: Dictionary = {}
var locked_patterns: Array = []
var studiable_patterns: Array = []
var owned_patterns: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_patterns()
	temporary_fix()
	GlobalSignal.game_start.connect(initialize)

func temporary_fix():
	for pattern in all_patterns.values():
		for attribute_idx in pattern["attribute"]:
			pattern["attribute"][attribute_idx] = pattern["attribute"][attribute_idx] * 2

func load_patterns():
	all_patterns.clear()
	var dir = DirAccess.open(PATTERNS_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", PATTERNS_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = PATTERNS_DIR + file_name
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
						"title": data.get("title", "Untitled"),
						"icon": icon,
						"attribute": data.get("attribute", ""),
						"description": data.get("description", ""),
						"abstract": data.get("abstract", ""),
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
	locked_patterns = all_patterns.keys()
	studiable_patterns.clear()
	owned_patterns.clear()
	var random_pattern = prepare_random_patterns(1)
	study_pattern(random_pattern, random_pattern[0])
#endregion

#region Array Operation
func get_pattern_by_key(key: String) -> Dictionary:
	return all_patterns.get(key, {})

func prepare_random_patterns(count: int = 3) -> Array:
	var shuffled = locked_patterns.duplicate()
	shuffled.shuffle()
	var selected = shuffled.slice(0, count)
	for pattern_entry in selected:
		locked_patterns.erase(pattern_entry)
		studiable_patterns.append(pattern_entry)
	return selected

func study_pattern(studiable_patterns_list: Array, target_pattern_key: String):
	for pattern_entry in studiable_patterns_list:
		if studiable_patterns.has(pattern_entry):
			studiable_patterns.erase(pattern_entry)
			if pattern_entry == target_pattern_key:
				owned_patterns.append(pattern_entry)
			else:
				locked_patterns.append(pattern_entry)
		else:
			push_error("study_pattern: No pattern with key " + pattern_entry + " found in studiable_patterns_list")
#endregion
