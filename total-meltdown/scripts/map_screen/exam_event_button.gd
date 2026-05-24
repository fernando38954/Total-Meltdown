extends BaseEventButton
class_name ExamEventButton

var actived_exam: String

func initialize_data():
	actived_exam = ExamManager.prepare_random_exam()

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_exam_screen(actived_exam)
