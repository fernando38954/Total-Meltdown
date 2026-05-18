extends Node

const QUEST_DIR = "res://contents/quest/"

var all_quests: Dictionary = {}
var pending_quests: Array = []
var actived_quests: Array = []
var accepted_quests: Array = []
var completed_quests: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_quests()
	GlobalSignal.game_start.connect(initialize)

func load_quests():
	all_quests.clear()
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
					var key = data.get("key", "Unknown")
					var icon = load(data.get("icon", ""))
					if !icon:
						push_error("Error: Unable to load image:", data.get("icon", ""))
					all_quests[key] = {
						"key": key,
						"title": data.get("title", "Untitled"),
						"icon": icon,
						"attribute": data.get("attribute", {}),
						"description": data.get("description", {}),
						"bullet_point": data.get("bullet_point", {}),
						"footnote": data.get("footnote", ""),
						"requirements": data.get("requirements", {}),
					}
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	creation_finished = true
	print_debug("Number of quests loaded：", all_quests.size())

func initialize():
	pending_quests = all_quests.keys()
	actived_quests.clear()
	accepted_quests.clear()
	completed_quests.clear()
#endregion

#region Array Operation
func get_quest_by_key(key: String) -> Dictionary:
	return all_quests.get(key, {})

func prepare_random_quest() -> String:
	if pending_quests.is_empty():
		return ""
	var quest_entry = pending_quests.pick_random()
	pending_quests.erase(quest_entry)
	actived_quests.append(quest_entry)
	return quest_entry

func start_quest(target_quest_key: String):
	if actived_quests.has(target_quest_key):
		actived_quests.erase(target_quest_key)
		accepted_quests.append(target_quest_key)
	else:
		push_error("start_quest: No quest with key " + target_quest_key + " found in actived_quests")

func complete_quest(target_quest_key: String):
	if accepted_quests.has(target_quest_key):
		accepted_quests.erase(target_quest_key)
		completed_quests.append(target_quest_key)
	else:
		push_error("complete_quest: No quest with key " + target_quest_key + " found in accepted_quests")
#endregion
