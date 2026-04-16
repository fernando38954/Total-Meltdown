extends Node

const CHAPTERS_DIR = "res://contents/swebok/"

var all_chapters: Array = []
var locked_chapters: Array = []
var studiable_chapters: Array = []
var owned_chapters: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_chapters()
	locked_chapters = all_chapters.duplicate()

func load_chapters():
	all_chapters.clear()
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
					all_chapters.append({
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
	
	all_chapters.sort_custom(func(a, b): return a.file_name < b.file_name)
	creation_finished = true
	print_debug("Number of chapters loaded：", all_chapters.size())
#endregion

#region Array Operation
func find_chapter(target_chapter_file_name: String):
	for chapter_entry in all_chapters:
		if chapter_entry.file_name == target_chapter_file_name:
			return chapter_entry
	push_warning("No developer with file_name" + target_chapter_file_name + "found")
	return {}

func prepare_random_chapters(count: int = 3) -> Array:
	var number = min(count, locked_chapters.size())
	var shuffled = locked_chapters.duplicate()
	shuffled.shuffle()
	var selected = shuffled.slice(0, number)
	
	for chapter_entry in selected:
		locked_chapters.erase(chapter_entry)
		studiable_chapters.append(chapter_entry)
	return selected

func study_chapter(studiable_chapters_list: Array, target_chapter_data: Dictionary):
	for chapter_entry in studiable_chapters_list:
		if studiable_chapters.has(chapter_entry):
			studiable_chapters.erase(chapter_entry)
			if chapter_entry == target_chapter_data:
				owned_chapters.append(chapter_entry)
			else:
				locked_chapters.append(chapter_entry)
		else:
			push_error("study_chapter: No chapter with file_name" + chapter_entry.file_name + "found in studiable_chapters_list")
#endregion
