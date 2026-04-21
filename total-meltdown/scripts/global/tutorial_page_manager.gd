extends Node

const TUTORIAL_PAGE_DIR = "res://contents/tutorial_page/"

var all_pages: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_pages()

func load_pages():
	all_pages.clear()
	var dir = DirAccess.open(TUTORIAL_PAGE_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", TUTORIAL_PAGE_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = TUTORIAL_PAGE_DIR + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					var image = load(data.get("image", ""))
					if !image:
						push_error("Error: Unable to load image:", data.get("image", ""))
					all_pages.append({
						"file_name": file_name,
						"order": data.get("order", "1024"),
						"title": data.get("title", "Untitled"),
						"image": image,
						"description": data.get("description", ""),
					})
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	all_pages.sort_custom(func(a, b): return a.order < b.order)
	creation_finished = true
	print_debug("Number of tutorial pages loaded：", all_pages.size())
#endregion
