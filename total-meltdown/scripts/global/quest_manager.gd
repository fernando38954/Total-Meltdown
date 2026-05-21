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
	process_attributes()
	GlobalSignal.game_start.connect(initialize)

func calculate_base_reward(difficult: String) -> int:
	match difficult.to_lower():
		"easy":
			return 80
		"medium":
			return 100
		"hard":
			return 120
		_:
			push_error("Unknown difficulty: ", difficult)
			return 0

func translate_attribute_level(level: String):
	var numeric_value: float = 0.0
	match level.to_lower():
		"irrelevant":
			numeric_value = randf_range(0.0, 1.0)
		"low":
			numeric_value = randf_range(2.0, 4.0)
		"medium":
			numeric_value = randf_range(5.0, 6.0)
		"high":
			numeric_value = randf_range(8.0, 10.0)
		_:
			push_error("Unknown attribute level: ", level)
	return round(numeric_value * 10) / 10.0

func process_attributes():
	for quest in all_quests.values():
		for attribute_idx in quest["attribute"]:
			quest["attribute"][attribute_idx] = translate_attribute_level(quest["attribute"][attribute_idx])

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
						"quarter": data.get("quarter", -1),
						"title": data.get("title", "Untitled"),
						"icon": icon,
						"difficult": data.get("difficult", "Undefined"),
						"base_reward": calculate_base_reward(data.get("difficult", "Undefined")),
						"attribute": data.get("attribute", {}),
						"description": data.get("description", {}),
						"bullet_point": data.get("bullet_point", {}),
						"footnote": data.get("footnote", ""),
						"requirements": data.get("requirements", {}),
						"bug": data.get("bug", {}),
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
