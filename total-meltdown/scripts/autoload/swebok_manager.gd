extends Node

const CHAPTERS_DIR = "res://contents/swebok/"

var chapters: Array = []
var owned_chapters: Array = []
var remaining_chapters: Array = []
var creation_finished = false

func _ready():
	load_chapters()
	remaining_chapters = chapters.duplicate()

func load_chapters():
	chapters.clear()
	var dir = DirAccess.open(CHAPTERS_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", CHAPTERS_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = CHAPTERS_DIR + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					var icon = load(data.get("icon", ""))
					if !icon:
						push_error("Error: Unable to load image:", data.get("icon", ""))
					chapters.append({
						"file_name": file_name,
						"title": data.get("title", "Untitled"),
						"icon": icon,
						"attribute": data.get("attribute", ""),
						"description": data.get("description", ""),
					})
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	chapters.sort_custom(func(a, b): return a.file_name < b.file_name)
	creation_finished = true
	print_debug("Number of chapters loaded：", chapters.size())

func find_chapter(target_chapter_file_name: String):
	for chapter_entry in chapters:
		if chapter_entry.file_name == target_chapter_file_name:
			return chapter_entry
	push_warning("No developer with file_name" + target_chapter_file_name + "found")
	return {}

func study_chapter(target_chapter_file_name: String) -> bool:
	for chapter_entry in remaining_chapters:
		if chapter_entry.file_name == target_chapter_file_name:
			remaining_chapters.erase(chapter_entry)
			owned_chapters.append(chapter_entry)
			return true
	push_warning("No developer with file_name" + target_chapter_file_name + "found")
	return false
