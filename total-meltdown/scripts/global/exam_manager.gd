extends Node

const EXAMS_DIR = "res://contents/exam/"
const QUIZ_SCENE = preload("res://scenes/component/QuizPanel.tscn")

var all_exams: Dictionary = {}
var unfinished_exams: Array = []
var actived_exams: Array = []
var completed_exams: Array = []
var creation_finished = false

#region Load Data
func _ready():
	load_exams()
	GlobalSignal.game_start.connect(initialize)

func load_exams():
	all_exams.clear()
	var dir = DirAccess.open(EXAMS_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", EXAMS_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = EXAMS_DIR + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					var key = data.get("key", "Unknown")
					all_exams[key] = {
						"key": key,
						"quarter": data.get("quarter", -1),
						"exam": data.get("exam", {}),
					}
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	creation_finished = true
	print_debug("Number of exams loaded：", all_exams.size())

func initialize():
	unfinished_exams.clear()
	for i in range(GlobalResource.TOTAL_QUARTER):
		unfinished_exams.append([])
	for exam_key in all_exams.keys():
		var exam_data = get_exam_by_key(exam_key)
		unfinished_exams[exam_data.quarter].append(exam_key)
	
	completed_exams.clear()
#endregion

#region Array Operation
func get_exam_by_key(key: String) -> Dictionary:
	return all_exams.get(key, {})

func prepare_random_exam() -> String:
	var exam_stock = unfinished_exams[GlobalResource.current_quarter]
	if exam_stock.is_empty():
		return ""
	var exam_entry = exam_stock.pick_random()
	exam_stock.erase(exam_entry)
	actived_exams.append(exam_entry)
	return exam_entry

func start_exam(target_exam_key: String):
	var quiz = QUIZ_SCENE.instantiate()
	var exam_data = get_exam_by_key(target_exam_key)
	get_tree().root.add_child(quiz)
	quiz.set_quiz(QuizPanel.QuizType.Exam, exam_data.exam, target_exam_key)

func finish_exam(target_exam_key: String, correct_counter: int):
	if target_exam_key in actived_exams:
		actived_exams.erase(target_exam_key)
		completed_exams.append(target_exam_key)
		GlobalSignal.emit_signal("current_map_event_finished")
		GlobalResource.show_quarter_report(correct_counter)
	else:
		push_error("finish_exam: No exam with key " + target_exam_key + " found in actived_exams")
#endregion
