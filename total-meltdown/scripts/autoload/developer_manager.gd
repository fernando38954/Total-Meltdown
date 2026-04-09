extends Node

const DEVELOPERS_DIR = "res://contents/developer/"

var developers: Array = []
var owned_developers: Array = []
var creation_finished = false

func _ready():
	load_developers()

func load_developers():
	developers.clear()
	var dir = DirAccess.open(DEVELOPERS_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", DEVELOPERS_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = DEVELOPERS_DIR + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					var portrait = load(data.get("portrait", ""))
					if !portrait:
						push_error("Error: Unable to load image:", data.get("portrait", ""))
					developers.append({
						"file_name": file_name,
						"name": data.get("name", "Untitled"),
						"portrait": portrait,
						"attribute": data.get("attribute", ""),
						"description": data.get("description", ""),
					})
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	developers.sort_custom(func(a, b): return a.file_name < b.file_name)
	creation_finished = true
	print_debug("Number of developers loaded：", developers.size())

func hire_developer(target_developer_file_name: String) -> bool:
	for developer_entry in developers:
		if developer_entry.file_name == target_developer_file_name:
			owned_developers.append(developer_entry)
			return true
	push_warning("No developer with file_name" + target_developer_file_name + "found")
	return false
