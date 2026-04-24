extends Node

const DEVELOPERS_DIR = "res://contents/developer/"

var all_developers: Array = []
var locked_developers: Array = []
var recruitable_developers: Array = []
var idle_developers: Array = []
var working_developers: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_developers()
	locked_developers = all_developers.duplicate()
	initialize()

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
					var portrait = load(data.get("portrait", ""))
					if !portrait:
						push_error("Error: Unable to load image:", data.get("portrait", ""))
					all_developers.append({
						"file_name": file_name,
						"name": data.get("name", "Unknown"),
						"portrait": portrait,
						"attribute": data.get("attribute", {}),
						"description": data.get("description", ""),
					})
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	all_developers.sort_custom(func(a, b): return a.file_name < b.file_name)
	creation_finished = true
	print_debug("Number of developers loaded：", all_developers.size())

func initialize():
	var random_developer = prepare_random_developers(1)
	hire_developer(random_developer, random_developer[0])
#endregion

#region Array Operation
func prepare_random_developers(count: int = 3) -> Array:
	var number = min(count, locked_developers.size())
	var shuffled = locked_developers.duplicate()
	shuffled.shuffle()
	var selected = shuffled.slice(0, number)
	
	for developer_entry in selected:
		locked_developers.erase(developer_entry)
		recruitable_developers.append(developer_entry)
	return selected

func hire_developer(recruitable_developers_list: Array, target_developer_data: Dictionary):
	GlobalResource.pay_developer_price()
	for developer_entry in recruitable_developers_list:
		if recruitable_developers.has(developer_entry):
			recruitable_developers.erase(developer_entry)
			if developer_entry == target_developer_data:
				idle_developers.append(developer_entry)
			else:
				locked_developers.append(developer_entry)
		else:
			push_error("hire_developer: No developer with file_name " + developer_entry.file_name + " found in recruitable_developers")

func assign_work(developers_list: Array):
	for developer_entry in developers_list:
		if idle_developers.has(developer_entry):
			idle_developers.erase(developer_entry)
			working_developers.append(developer_entry)
		else:
			push_error("assign_work: No developer with file_name " + developer_entry.file_name + " found in idle_developers")

func finish_work(developers_list: Array):
	for developer_entry in developers_list:
		if working_developers.has(developer_entry):
			working_developers.erase(developer_entry)
			idle_developers.append(developer_entry)
		else:
			push_error("finish_work: No developer with file_name " + developer_entry.file_name + " found in working_developers")
#endregion
