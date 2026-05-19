extends Node

const DEVELOPERS_DIR = "res://contents/developer/"

var all_developers: Dictionary = {}
var locked_developers: Array = []
var recruitable_developers: Array = []
var owned_developers: Array = []
var idle_developers: Array = []
var working_developers: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_developers()
	GlobalSignal.game_start.connect(initialize)

func load_developers():
	all_developers.clear()
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
					var key = data.get("key", "Unknown")
					var portrait = load(data.get("portrait", ""))
					if !portrait:
						push_error("Error: Unable to load image:", data.get("portrait", ""))
					all_developers[key] = {
						"key": key,
						"name": data.get("name", "Unknown"),
						"portrait": portrait,
						"cost": data.get("cost", 0),
						"attribute": data.get("attribute", {}),
						"description": data.get("description", ""),
					}
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	creation_finished = true
	print_debug("Number of developers loaded：", all_developers.size())

func initialize():
	locked_developers = all_developers.keys()
	recruitable_developers.clear()
	idle_developers.clear()
	working_developers.clear()
	var random_developer = prepare_random_developers(1)
	hire_developer(random_developer, random_developer[0])
#endregion

#region Array Operation
func get_developer_by_key(key: String) -> Dictionary:
	return all_developers.get(key, {})

func prepare_random_developers(count: int = 2) -> Array:
	var shuffled = locked_developers.duplicate()
	shuffled.shuffle()
	var selected = shuffled.slice(0, count)
	for developer_entry in selected:
		locked_developers.erase(developer_entry)
		recruitable_developers.append(developer_entry)
	return selected

func hire_developer(recruitable_developers_list: Array, target_developer_data: String):
	for developer_entry in recruitable_developers_list:
		if recruitable_developers.has(developer_entry):
			recruitable_developers.erase(developer_entry)
			if developer_entry == target_developer_data:
				owned_developers.append(developer_entry)
				idle_developers.append(developer_entry)
				pay_developer(developer_entry)
			else:
				locked_developers.append(developer_entry)
		else:
			push_error("hire_developer: No developer with key " + developer_entry + " found in recruitable_developers")
	GlobalSignal.emit_signal("developer_panel_update")

func pay_developer(target_developer_key: String):
	var developer_data = get_developer_by_key(target_developer_key)
	GlobalResource.change_money(-1 * developer_data.cost)

func assign_work(developers_list: Array):
	for developer_entry in developers_list:
		if idle_developers.has(developer_entry):
			idle_developers.erase(developer_entry)
			working_developers.append(developer_entry)
		else:
			push_error("assign_work: No developer with key " + developer_entry + " found in idle_developers")
	GlobalSignal.emit_signal("developer_panel_update")

func finish_work(developers_list: Array):
	for developer_entry in developers_list:
		if working_developers.has(developer_entry):
			working_developers.erase(developer_entry)
			idle_developers.append(developer_entry)
		else:
			push_error("finish_work: No developer with key " + developer_entry + " found in working_developers")
	GlobalSignal.emit_signal("developer_panel_update")
#endregion
