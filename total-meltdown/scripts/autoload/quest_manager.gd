extends Node

const QUEST_DIR = "res://contents/quest/"

var quests: Array = []
var remaining_quests: Array = []
var creation_finished = false

func _ready():
	load_quests()
	remaining_quests = quests.duplicate()

func load_quests():
	quests.clear()
	var dir = DirAccess.open(QUEST_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", QUEST_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = QUEST_DIR + file_name
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
					quests.append({
						"file_name": file_name,
						"title": data.get("title", "Untitled"),
						"icon": icon,
						"attribute": data.get("attribute", {}),
						"description": data.get("description", {}),
						"bullet_point": data.get("bullet_point", {}),
						"footnote": data.get("footnote", ""),
						"requirements": data.get("requirements", {}),
					})
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	quests.sort_custom(func(a, b): return a.file_name < b.file_name)
	creation_finished = true
	print_debug("Number of quests loaded：", quests.size())

func complete_quest(target_quest_file_name: String) -> bool:
	for quest_entry in remaining_quests:
		if quest_entry.file_name == target_quest_file_name:
			remaining_quests.erase(quest_entry)
			return true
	push_warning("No quest with file_name" + target_quest_file_name + "found")
	return false
